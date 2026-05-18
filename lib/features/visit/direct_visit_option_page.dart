import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_card.dart';
import '../../data/models/plan_visit_open_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/direct_visit_service.dart';
import 'direct_visit_form_page.dart';

class DirectVisitOptionPage extends StatefulWidget {
  final UserModel user;

  const DirectVisitOptionPage({
    super.key,
    required this.user,
  });

  @override
  State<DirectVisitOptionPage> createState() => _DirectVisitOptionPageState();
}

class _DirectVisitOptionPageState extends State<DirectVisitOptionPage> {
  final _directVisitService = DirectVisitService();

  late Future<List<PlanVisitOpenModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadOpenPlans();
  }

  Future<List<PlanVisitOpenModel>> _loadOpenPlans() {
    return _directVisitService.getOpenPlanVisits(
      userId: widget.user.userId,
    );
  }

  void _refresh() {
    setState(() {
      _future = _loadOpenPlans();
    });
  }

  void _openDirectForm({PlanVisitOpenModel? plan}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DirectVisitFormPage(
          user: widget.user,
          plan: plan,
        ),
      ),
    ).then((_) {
      _refresh();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Visit'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            AppButton(
              text: 'Direct Visit Langsung',
              onPressed: () => _openDirectForm(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Plan Visit Belum Direalisasikan',
              style: TextStyle(
                color: Color(0xFF232ACB),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            FutureBuilder<List<PlanVisitOpenModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'Gagal mengambil data plan visit.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text('Tidak ada Plan Visit OPEN'),
                    ),
                  );
                }

                return Column(
                  children: data.map((item) {
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 14),
                      onTap: () => _openDirectForm(plan: item),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(item.visitDate),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.dealerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.areaName} - ${item.branchName}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.purposeName,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}