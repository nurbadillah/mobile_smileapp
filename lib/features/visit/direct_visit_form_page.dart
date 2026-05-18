import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_dropdown.dart';
import '../../common/widgets/app_text_area.dart';
import '../../common/widgets/app_text_field.dart';
import '../../common/widgets/section_title.dart';
import '../../data/models/area_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/dealer_model.dart';
import '../../data/models/master_item_model.dart';
import '../../data/models/plan_visit_open_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/direct_visit_service.dart';
import '../../data/services/master_service.dart';
import '../../data/services/upload_service.dart';

class DirectVisitFormPage extends StatefulWidget {
  final UserModel user;
  final PlanVisitOpenModel? plan;

  const DirectVisitFormPage({
    super.key,
    required this.user,
    this.plan,
  });

  @override
  State<DirectVisitFormPage> createState() => _DirectVisitFormPageState();
}

class _DirectVisitFormPageState extends State<DirectVisitFormPage> {
  final _masterService = MasterService();
  final _directVisitService = DirectVisitService();
  final _uploadService = UploadService();
  final _imagePicker = ImagePicker();

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _picNameController = TextEditingController();
  final _themeController = TextEditingController();
  final _problemController = TextEditingController();
  final _actionController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _personNameController = TextEditingController();
  final _personPhoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  double? _latitude;
  double? _longitude;

  final List<File> _selectedPhotos = [];

  List<MasterItemModel> _internalPositions = [];
  List<AreaModel> _areas = [];
  List<BranchModel> _branches = [];
  List<DealerModel> _dealers = [];
  List<MasterItemModel> _products = [];
  List<MasterItemModel> _visitTypes = [];
  List<MasterItemModel> _visitPurposes = [];
  List<MasterItemModel> _dealerPositions = [];

  int? _selectedInternalPositionId;
  int? _selectedAreaId;
  int? _selectedBranchId;
  int? _selectedDealerId;
  int? _selectedProductId;
  int? _selectedVisitTypeId;
  int? _selectedPurposeId;
  int? _selectedDealerPositionId;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  final List<Map<String, dynamic>> _persons = [];

  bool get _isFromPlan => widget.plan != null;

  @override
  void initState() {
    super.initState();

    _selectedInternalPositionId = widget.user.internalPositionId;

    if (_isFromPlan) {
      final plan = widget.plan!;
      _selectedAreaId = plan.areaId;
      _selectedBranchId = plan.branchId;
      _selectedDealerId = plan.dealerId;
      _selectedPurposeId = plan.purposeId;

      if (plan.visitDate != null) {
        _selectedStartDate = plan.visitDate;
        _selectedEndDate = plan.visitDate;
        _startDateController.text = DateFormat('dd/MM/yyyy').format(plan.visitDate!);
        _endDateController.text = DateFormat('dd/MM/yyyy').format(plan.visitDate!);
      }
    }

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _masterService.getInternalPositions(),
        _masterService.getAreas(),
        _masterService.getProducts(),
        _masterService.getVisitTypes(),
        _masterService.getDealerPositions(),
      ]);

      final internalPositions = results[0] as List<MasterItemModel>;
      final areas = results[1] as List<AreaModel>;
      final products = results[2] as List<MasterItemModel>;
      final visitTypes = results[3] as List<MasterItemModel>;
      final dealerPositions = results[4] as List<MasterItemModel>;

      List<BranchModel> branches = [];
      List<DealerModel> dealers = [];

      if (_selectedAreaId != null) {
        branches = await _masterService.getBranches(areaId: _selectedAreaId);
      }

      if (_selectedBranchId != null) {
        dealers = await _masterService.getDealers(branchId: _selectedBranchId);
      }

      if (!mounted) return;

      setState(() {
        _internalPositions = internalPositions;
        _areas = areas;
        _products = products;
        _visitTypes = visitTypes;
        _dealerPositions = dealerPositions;
        _branches = branches;
        _dealers = dealers;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Gagal mengambil data master');
    }
  }

  Future<void> _loadBranches(int areaId) async {
    setState(() {
      _selectedAreaId = areaId;
      _selectedBranchId = null;
      _selectedDealerId = null;
      _branches = [];
      _dealers = [];
    });

    try {
      final data = await _masterService.getBranches(areaId: areaId);

      if (!mounted) return;

      setState(() {
        _branches = data;
      });
    } catch (_) {
      _showMessage('Gagal mengambil data cabang');
    }
  }

  Future<void> _loadDealers(int branchId) async {
    setState(() {
      _selectedBranchId = branchId;
      _selectedDealerId = null;
      _dealers = [];
    });

    try {
      final data = await _masterService.getDealers(branchId: branchId);

      if (!mounted) return;

      setState(() {
        _dealers = data;
      });
    } catch (_) {
      _showMessage('Gagal mengambil data dealer');
    }
  }

  Future<void> _loadVisitPurposes(int visitTypeId) async {
    setState(() {
      _selectedVisitTypeId = visitTypeId;

      if (!_isFromPlan) {
        _selectedPurposeId = null;
      }

      _visitPurposes = [];
    });

    try {
      final data = await _masterService.getVisitPurposes(
        tipeVisitId: visitTypeId,
      );

      if (!mounted) return;

      setState(() {
        _visitPurposes = data;
      });
    } catch (_) {
      _showMessage('Gagal mengambil data tujuan visit');
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_selectedStartDate ?? now)
          : (_selectedEndDate ?? _selectedStartDate ?? now),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _selectedStartDate = picked;
        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);

        if (_selectedEndDate == null || _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = picked;
          _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      } else {
        _selectedEndDate = picked;
        _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage('Layanan lokasi belum aktif');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showMessage('Izin lokasi ditolak');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage('Izin lokasi ditolak permanen. Aktifkan dari settings.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      _showMessage('Lokasi berhasil diambil');
    } catch (_) {
      _showMessage('Gagal mengambil lokasi');
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedPhotos.add(File(pickedFile.path));
      });
    } catch (_) {
      _showMessage('Gagal memilih foto');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _addPerson() {
    if (_selectedDealerPositionId == null) {
      _showMessage('Jabatan main person wajib dipilih');
      return;
    }

    if (_personNameController.text.trim().isEmpty) {
      _showMessage('Nama main person wajib diisi');
      return;
    }

    setState(() {
      _persons.add({
        'dealerPositionId': _selectedDealerPositionId,
        'picName': _personNameController.text.trim(),
        'phone': _personPhoneController.text.trim(),
      });

      _selectedDealerPositionId = null;
      _personNameController.clear();
      _personPhoneController.clear();
    });
  }

  void _removePerson(int index) {
    setState(() {
      _persons.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_selectedInternalPositionId == null) {
      _showMessage('Jabatan wajib dipilih');
      return;
    }

    if (_selectedAreaId == null) {
      _showMessage('Area wajib dipilih');
      return;
    }

    if (_selectedBranchId == null) {
      _showMessage('Cabang wajib dipilih');
      return;
    }

    if (_selectedDealerId == null) {
      _showMessage('Dealer wajib dipilih');
      return;
    }

    if (_selectedProductId == null) {
      _showMessage('Produk wajib dipilih');
      return;
    }

    if (_selectedVisitTypeId == null) {
      _showMessage('Tipe visit wajib dipilih');
      return;
    }

    if (_selectedPurposeId == null) {
      _showMessage('Tujuan visit wajib dipilih');
      return;
    }

    if (_selectedStartDate == null) {
      _showMessage('Dari tanggal wajib dipilih');
      return;
    }

    if (_selectedEndDate == null) {
      _showMessage('Sampai tanggal wajib dipilih');
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      _showMessage('Sampai tanggal tidak boleh sebelum dari tanggal');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final visitId = await _directVisitService.createDirectVisit(
        planVisitId: widget.plan?.visitId,
        userId: widget.user.userId,
        internalPositionId: _selectedInternalPositionId!,
        areaId: _selectedAreaId!,
        branchId: _selectedBranchId!,
        dealerId: _selectedDealerId!,
        productId: _selectedProductId!,
        visitTypeId: _selectedVisitTypeId!,
        purposeId: _selectedPurposeId!,
        startDate: _selectedStartDate!,
        endDate: _selectedEndDate!,
        picName: _picNameController.text.trim(),
        themeDiscussion: _themeController.text.trim(),
        problemPending: _problemController.text.trim(),
        actionFollowUp: _actionController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        persons: _persons,
      );

      for (final photo in _selectedPhotos) {
        await _uploadService.uploadVisitPhoto(
          visitId: visitId,
          photoFile: photo,
        );
      }

      if (!mounted) return;

      _showMessage('Direct visit berhasil disimpan');

      Navigator.pop(context);
    } catch (_) {
      _showMessage('Gagal menyimpan direct visit');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  List<AppDropdownItem> _mapMasterItems(List<MasterItemModel> data) {
    return data
        .map(
          (item) => AppDropdownItem(
            id: item.id,
            name: item.name,
          ),
        )
        .toList();
  }

  List<AppDropdownItem> _mapAreas(List<AreaModel> data) {
    return data
        .map(
          (item) => AppDropdownItem(
            id: item.areaId,
            name: item.areaName,
          ),
        )
        .toList();
  }

  List<AppDropdownItem> _mapBranches(List<BranchModel> data) {
    return data
        .map(
          (item) => AppDropdownItem(
            id: item.branchId,
            name: item.branchName,
          ),
        )
        .toList();
  }

  List<AppDropdownItem> _mapDealers(List<DealerModel> data) {
    return data
        .map(
          (item) => AppDropdownItem(
            id: item.dealerId,
            name: item.dealerName,
          ),
        )
        .toList();
  }

  String _dealerPositionName(int id) {
    final found = _dealerPositions.where((item) => item.id == id);
    if (found.isEmpty) return '-';
    return found.first.name;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _picNameController.dispose();
    _themeController.dispose();
    _problemController.dispose();
    _actionController.dispose();
    _descriptionController.dispose();
    _personNameController.dispose();
    _personPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isFromPlan ? 'Realisasi Plan Visit' : 'Form Direct Visit';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_isFromPlan) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(text: 'Plan Visit Terpilih'),
                          const SizedBox(height: 16),
                          Text('Dealer: ${widget.plan!.dealerName}'),
                          Text('Area: ${widget.plan!.areaName}'),
                          Text('Cabang: ${widget.plan!.branchName}'),
                          Text('Tujuan: ${widget.plan!.purposeName}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  AppCard(
                    child: Column(
                      children: [
                        const SectionTitle(text: 'Jabatan Saya'),
                        const SizedBox(height: 18),
                        AppDropdown(
                          label: 'Jabatan',
                          hint: '--Pilih--',
                          value: _selectedInternalPositionId,
                          items: _mapMasterItems(_internalPositions),
                          onChanged: (value) {
                            setState(() {
                              _selectedInternalPositionId = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      children: [
                        const SectionTitle(text: 'Data Dealer'),
                        const SizedBox(height: 18),
                        AppDropdown(
                          label: 'Area',
                          hint: '--Pilih--',
                          value: _selectedAreaId,
                          items: _mapAreas(_areas),
                          onChanged: _isFromPlan
                              ? (_) {}
                              : (value) {
                                  if (value != null) {
                                    _loadBranches(value);
                                  }
                                },
                        ),
                        const SizedBox(height: 14),
                        AppDropdown(
                          label: 'Cabang',
                          hint: '--Pilih--',
                          value: _selectedBranchId,
                          items: _mapBranches(_branches),
                          onChanged: _isFromPlan
                              ? (_) {}
                              : (value) {
                                  if (value != null) {
                                    _loadDealers(value);
                                  }
                                },
                        ),
                        const SizedBox(height: 14),
                        AppDropdown(
                          label: 'Dealer',
                          hint: '--Pilih--',
                          value: _selectedDealerId,
                          items: _mapDealers(_dealers),
                          onChanged: _isFromPlan
                              ? (_) {}
                              : (value) {
                                  setState(() {
                                    _selectedDealerId = value;
                                  });
                                },
                        ),
                        const SizedBox(height: 14),
                        AppDropdown(
                          label: 'Produk',
                          hint: '--Pilih--',
                          value: _selectedProductId,
                          items: _mapMasterItems(_products),
                          onChanged: (value) {
                            setState(() {
                              _selectedProductId = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      children: [
                        const SectionTitle(text: 'Data Visit'),
                        const SizedBox(height: 18),
                        AppDropdown(
                          label: 'Tipe Visit',
                          hint: '--Pilih--',
                          value: _selectedVisitTypeId,
                          items: _mapMasterItems(_visitTypes),
                          onChanged: (value) {
                            if (value != null) {
                              _loadVisitPurposes(value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        AppDropdown(
                          label: 'Tujuan Visit',
                          hint: '--Pilih--',
                          value: _selectedPurposeId,
                          items: _isFromPlan && _visitPurposes.isEmpty
                              ? [
                                  AppDropdownItem(
                                    id: widget.plan!.purposeId,
                                    name: widget.plan!.purposeName,
                                  )
                                ]
                              : _mapMasterItems(_visitPurposes),
                          onChanged: _isFromPlan
                              ? (_) {}
                              : (value) {
                                  setState(() {
                                    _selectedPurposeId = value;
                                  });
                                },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Dari tanggal',
                          hint: 'dd/mm/yyyy',
                          controller: _startDateController,
                          readOnly: true,
                          onTap: () => _pickDate(isStart: true),
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Sampai tanggal',
                          hint: 'dd/mm/yyyy',
                          controller: _endDateController,
                          readOnly: true,
                          onTap: () => _pickDate(isStart: false),
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Nama PIC',
                          controller: _picNameController,
                          maxLength: 50,
                        ),
                        const SizedBox(height: 14),
                        AppTextArea(
                          label: 'Theme of discussion',
                          controller: _themeController,
                        ),
                        const SizedBox(height: 14),
                        AppTextArea(
                          label: 'Problem & pending matter',
                          controller: _problemController,
                        ),
                        const SizedBox(height: 14),
                        AppTextArea(
                          label: 'Action Follow Up',
                          controller: _actionController,
                        ),
                        const SizedBox(height: 14),
                        AppTextArea(
                          label: 'Deskripsi',
                          controller: _descriptionController,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      children: [
                        const SectionTitle(text: 'Main Person'),
                        const SizedBox(height: 18),
                        AppDropdown(
                          label: 'Jabatan',
                          hint: '--Pilih--',
                          value: _selectedDealerPositionId,
                          items: _mapMasterItems(_dealerPositions),
                          onChanged: (value) {
                            setState(() {
                              _selectedDealerPositionId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Nama PIC',
                          controller: _personNameController,
                          maxLength: 50,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'No Telepon PIC',
                          hint: '+62',
                          controller: _personPhoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 15,
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: _addPerson,
                          child: const Text('tambahkan'),
                        ),
                        if (_persons.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Column(
                            children: List.generate(_persons.length, (index) {
                              final person = _persons[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(person['picName'] ?? ''),
                                subtitle: Text(
                                  '${_dealerPositionName(person['dealerPositionId'] ?? 0)} | ${person['phone'] ?? ''}',
                                ),
                                trailing: IconButton(
                                  onPressed: () => _removePerson(index),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              );
                            }),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      children: [
                        const SectionTitle(text: 'Upload Foto'),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickPhoto(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: const Text('Kamera'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickPhoto(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Galeri'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_selectedPhotos.isEmpty)
                          const Text('Belum ada foto dipilih')
                        else
                          Column(
                            children: List.generate(_selectedPhotos.length, (index) {
                              final photo = _selectedPhotos[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE0E0E0)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        photo,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        photo.path.split(Platform.pathSeparator).last,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removePhoto(index),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      children: [
                        const SectionTitle(text: 'Lokasi Visit'),
                        const SizedBox(height: 18),
                        if (_latitude == null || _longitude == null)
                          const Text('Lokasi belum diambil')
                        else ...[
                          Text('Latitude: $_latitude'),
                          const SizedBox(height: 6),
                          Text('Longitude: $_longitude'),
                        ],
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isGettingLocation ? null : _getCurrentLocation,
                            icon: _isGettingLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location),
                            label: Text(
                              _isGettingLocation
                                  ? 'Mengambil lokasi...'
                                  : 'Ambil Lokasi',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Submit',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
    );
  }
}