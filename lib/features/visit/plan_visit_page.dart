import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_dropdown.dart';
import '../../common/widgets/app_text_field.dart';
import '../../common/widgets/section_title.dart';
import '../../data/models/area_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/dealer_model.dart';
import '../../data/models/master_item_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/master_service.dart';
import '../../data/services/plan_visit_service.dart';

class PlanVisitPage extends StatefulWidget {
  final UserModel user;

  const PlanVisitPage({
    super.key,
    required this.user,
  });

  @override
  State<PlanVisitPage> createState() => _PlanVisitPageState();
}

class _PlanVisitPageState extends State<PlanVisitPage> {
  final _masterService = MasterService();
  final _planVisitService = PlanVisitService();
  final _dateController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;

  List<MasterItemModel> _internalPositions = [];
  List<AreaModel> _areas = [];
  List<BranchModel> _branches = [];
  List<DealerModel> _dealers = [];
  List<MasterItemModel> _visitPurposes = [];

  int? _selectedInternalPositionId;
  int? _selectedAreaId;
  int? _selectedBranchId;
  int? _selectedDealerId;
  int? _selectedPurposeId;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedInternalPositionId = widget.user.internalPositionId;
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
        _masterService.getVisitPurposes(),
      ]);

      if (!mounted) return;

      setState(() {
        _internalPositions = results[0] as List<MasterItemModel>;
        _areas = results[1] as List<AreaModel>;
        _visitPurposes = results[2] as List<MasterItemModel>;
        _isLoading = false;
      });
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      _showMessage('Gagal mengambil data dealer');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
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

    if (_selectedPurposeId == null) {
      _showMessage('Tujuan visit wajib dipilih');
      return;
    }

    if (_selectedDate == null) {
      _showMessage('Tanggal visit wajib dipilih');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _planVisitService.createPlanVisit(
        userId: widget.user.userId,
        internalPositionId: _selectedInternalPositionId!,
        areaId: _selectedAreaId!,
        branchId: _selectedBranchId!,
        dealerId: _selectedDealerId!,
        purposeId: _selectedPurposeId!,
        visitDate: _selectedDate!,
      );

      if (!mounted) return;

      _showMessage('Plan visit berhasil disimpan');

      Navigator.pop(context);
    } catch (e) {
      _showMessage('Gagal menyimpan plan visit');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Plan Visit'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
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
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Tanggal Visit',
                          hint: 'dd/mm/yyyy',
                          controller: _dateController,
                          readOnly: true,
                          onTap: _pickDate,
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
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