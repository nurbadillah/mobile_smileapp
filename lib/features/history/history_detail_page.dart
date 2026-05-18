import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/api_env.dart';
import '../../data/services/upload_service.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_dropdown.dart';
import '../../common/widgets/app_text_area.dart';
import '../../common/widgets/app_text_field.dart';
import '../../common/widgets/section_title.dart';
import '../../data/models/area_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/dealer_model.dart';
import '../../data/models/history_detail_model.dart';
import '../../data/models/master_item_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/history_service.dart';
import '../../data/services/master_service.dart';

class HistoryDetailPage extends StatefulWidget {
  final int visitId;
  final UserModel user;

  const HistoryDetailPage({
    super.key,
    required this.visitId,
    required this.user,
  });

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  final _historyService = HistoryService();
  final _masterService = MasterService();
  final _uploadService = UploadService();

  final _visitDateController = TextEditingController();
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
  bool _isSaving = false;
  bool _isDeleting = false;

  HistoryDetailModel? _detail;

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

  DateTime? _selectedVisitDate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  final List<Map<String, dynamic>> _persons = [];

  bool get _isPlan => _detail?.visitKind == 'PLAN';
  bool get _isDirect => _detail?.visitKind == 'DIRECT';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final detail = await _historyService.getDetail(
        visitId: widget.visitId,
      );

      final internalPositions = await _masterService.getInternalPositions();
      final areas = await _masterService.getAreas();
      final products = await _masterService.getProducts();
      final visitTypes = await _masterService.getVisitTypes();
      final dealerPositions = await _masterService.getDealerPositions();

      final branches = await _masterService.getBranches(
        areaId: detail.areaId,
      );

      final dealers = await _masterService.getDealers(
        branchId: detail.branchId,
      );

      List<MasterItemModel> purposes;

      if (detail.visitKind == 'DIRECT' && detail.visitTypeId != null) {
        purposes = await _masterService.getVisitPurposes(
          tipeVisitId: detail.visitTypeId,
        );
      } else {
        purposes = await _masterService.getVisitPurposes();
      }

      if (!mounted) return;

      setState(() {
        _detail = detail;

        _internalPositions = internalPositions;
        _areas = areas;
        _products = products;
        _visitTypes = visitTypes;
        _dealerPositions = dealerPositions;
        _branches = branches;
        _dealers = dealers;
        _visitPurposes = purposes;

        _selectedInternalPositionId = detail.internalPositionId;
        _selectedAreaId = detail.areaId;
        _selectedBranchId = detail.branchId;
        _selectedDealerId = detail.dealerId;
        _selectedProductId = detail.productId;
        _selectedVisitTypeId = detail.visitTypeId;
        _selectedPurposeId = detail.purposeId;

        _selectedVisitDate = detail.visitDate;
        _selectedStartDate = detail.startDate;
        _selectedEndDate = detail.endDate;

        _visitDateController.text = detail.visitDate == null
            ? ''
            : _formatDate(detail.visitDate);

        _startDateController.text = detail.startDate == null
            ? ''
            : _formatDate(detail.startDate);

        _endDateController.text = detail.endDate == null
            ? ''
            : _formatDate(detail.endDate);

        _picNameController.text = detail.picName ?? '';
        _themeController.text = detail.themeDiscussion ?? '';
        _problemController.text = detail.problemPending ?? '';
        _actionController.text = detail.actionFollowUp ?? '';
        _descriptionController.text = detail.description ?? '';

        _persons.clear();
        _persons.addAll(
          detail.persons.map((person) {
            return {
              'dealerPositionId': person.dealerPositionId,
              'picName': person.picName,
              'phone': person.phone ?? '',
            };
          }),
        );

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Gagal mengambil detail history');
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
      _showMessage('Gagal mengambil cabang');
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
      _showMessage('Gagal mengambil dealer');
    }
  }

  Future<void> _loadVisitPurposes(int visitTypeId) async {
    setState(() {
      _selectedVisitTypeId = visitTypeId;
      _selectedPurposeId = null;
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
      _showMessage('Gagal mengambil tujuan visit');
    }
  }

  Future<void> _pickDate(String type) async {
    final now = DateTime.now();

    DateTime? initialDate;

    if (type == 'visit') {
      initialDate = _selectedVisitDate;
    } else if (type == 'start') {
      initialDate = _selectedStartDate;
    } else {
      initialDate = _selectedEndDate ?? _selectedStartDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;

    setState(() {
      if (type == 'visit') {
        _selectedVisitDate = picked;
        _visitDateController.text = _formatDate(picked);
      }

      if (type == 'start') {
        _selectedStartDate = picked;
        _startDateController.text = _formatDate(picked);

        if (_selectedEndDate == null || _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = picked;
          _endDateController.text = _formatDate(picked);
        }
      }

      if (type == 'end') {
        _selectedEndDate = picked;
        _endDateController.text = _formatDate(picked);
      }
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

  Future<void> _save() async {
    if (_detail == null) return;

    if (_selectedInternalPositionId == null ||
        _selectedAreaId == null ||
        _selectedBranchId == null ||
        _selectedDealerId == null ||
        _selectedPurposeId == null) {
      _showMessage('Data wajib belum lengkap');
      return;
    }

    if (_isPlan && _selectedVisitDate == null) {
      _showMessage('Tanggal visit wajib dipilih');
      return;
    }

    if (_isDirect) {
      if (_selectedProductId == null) {
        _showMessage('Produk wajib dipilih');
        return;
      }

      if (_selectedVisitTypeId == null) {
        _showMessage('Tipe visit wajib dipilih');
        return;
      }

      if (_selectedStartDate == null || _selectedEndDate == null) {
        _showMessage('Tanggal direct visit wajib lengkap');
        return;
      }

      if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
        _showMessage('Tanggal selesai tidak boleh sebelum tanggal mulai');
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isPlan) {
        await _historyService.updatePlanVisit(
          visitId: widget.visitId,
          userId: _detail!.userId,
          internalPositionId: _selectedInternalPositionId!,
          areaId: _selectedAreaId!,
          branchId: _selectedBranchId!,
          dealerId: _selectedDealerId!,
          purposeId: _selectedPurposeId!,
          visitDate: _selectedVisitDate!,
        );
      } else {
        await _historyService.updateDirectVisit(
          visitId: widget.visitId,
          planVisitId: _detail!.planVisitId,
          userId: _detail!.userId,
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
          latitude: _detail!.latitude,
          longitude: _detail!.longitude,
          persons: _persons,
        );
      }

      if (!mounted) return;

      _showMessage('History berhasil diperbarui');

      await _loadAll();
    } catch (_) {
      _showMessage('Gagal memperbarui history');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus History'),
          content: const Text('Yakin ingin menghapus data ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _historyService.deleteHistory(
        visitId: widget.visitId,
      );

      if (!mounted) return;

      _showMessage('History berhasil dihapus');

      Navigator.pop(context);
    } catch (_) {
      _showMessage('Gagal menghapus history');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Foto'),
          content: const Text('Yakin ingin menghapus foto ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _uploadService.deleteVisitPhoto(photoId: photoId);

      if (!mounted) return;

      _showMessage('Foto berhasil dihapus');

      await _loadAll();
    } catch (_) {
      _showMessage('Gagal menghapus foto');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _text(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }

    return value;
  }

  String _dealerPositionName(int id) {
    final found = _dealerPositions.where((item) => item.id == id);
    if (found.isEmpty) return '-';
    return found.first.name;
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _visitDateController.dispose();
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
    final title = _detail?.visitKind == 'DIRECT'
        ? 'Detail Direct Visit'
        : 'Detail Plan Visit';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detail == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AppCard(
            child: Column(
              children: [
                const SectionTitle(text: 'Informasi Visit'),
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
                if (_isPlan) ...[
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Tanggal Visit',
                    hint: 'dd/mm/yyyy',
                    controller: _visitDateController,
                    readOnly: true,
                    onTap: () => _pickDate('visit'),
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ],
                if (_isDirect) ...[
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Dari Tanggal',
                    hint: 'dd/mm/yyyy',
                    controller: _startDateController,
                    readOnly: true,
                    onTap: () => _pickDate('start'),
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Sampai Tanggal',
                    hint: 'dd/mm/yyyy',
                    controller: _endDateController,
                    readOnly: true,
                    onTap: () => _pickDate('end'),
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ],
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
                  onChanged: (value) {
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
                  onChanged: (value) {
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
                  onChanged: (value) {
                    setState(() {
                      _selectedDealerId = value;
                    });
                  },
                ),
                if (_isDirect) ...[
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
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              children: [
                const SectionTitle(text: 'Data Visit'),
                const SizedBox(height: 18),
                if (_isDirect) ...[
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
                ],
                AppDropdown(
                  label: 'Tujuan Visit',
                  hint: '--Pilih--',
                  value: _selectedPurposeId,
                  items: _mapMasterItems(_visitPurposes),
                  onChanged: (value) {
                    setState(() {
                      _selectedPurposeId = value;
                    });
                  },
                ),
                if (_isDirect) ...[
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
              ],
            ),
          ),
          if (_isDirect) ...[
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
                            '${_dealerPositionName(person['dealerPositionId'] ?? 0)} | ${_text(person['phone'])}',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(text: 'Lokasi'),
                  const SizedBox(height: 18),
                  Text('Latitude: ${_detail!.latitude ?? '-'}'),
                  Text('Longitude: ${_detail!.longitude ?? '-'}'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(text: 'Foto'),
                  const SizedBox(height: 18),
                  if (_detail!.photos.isEmpty)
                    const Text('-')
                  else
                    Column(
                      children: _detail!.photos.map((photo) {
                        final imageUrl =
                            '${ApiEnv.fileBaseUrl}${photo.filePath}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 180,
                                      color: const Color(0xFFF1F1F1),
                                      alignment: Alignment.center,
                                      child: const Text('Gagal memuat foto'),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        photo.fileName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _deletePhoto(photo.photoId),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          AppButton(
            text: 'Save',
            isLoading: _isSaving,
            onPressed: _save,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _isDeleting ? null : _deleteHistory,
              child: _isDeleting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }
}