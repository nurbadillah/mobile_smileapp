import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/widgets/app_card.dart';
import '../../common/widgets/bottom_nav.dart';
import '../../data/models/history_list_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/history_service.dart';
import '../home/home_page.dart';
import '../master/master_menu_page.dart';
import 'history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  final UserModel user;

  const HistoryPage({
    super.key,
    required this.user,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _historyService = HistoryService();

  late Future<List<HistoryListModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadHistory();
  }

  Future<List<HistoryListModel>> _loadHistory() {
    return _historyService.getHistory();
  }

  void _refresh() {
    setState(() {
      _future = _loadHistory();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Color _statusColor(String status) {
    if (status == 'DONE') {
      return Colors.green;
    }

    if (status == 'OPEN') {
      return Colors.orange;
    }

    return Colors.grey;
  }

  void _openDetail(HistoryListModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryDetailPage(
          visitId: item.visitId,
          user: widget.user,
        ),
      ),
    ).then((_) {
      _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(user: widget.user),
              ),
            );
            return;
          }

          if (index == 1) {
            return;
          }

          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MasterMenuPage(user: widget.user),
              ),
            );
            return;
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<HistoryListModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Gagal mengambil history.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text('History belum tersedia'),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 14),
                  onTap: () => _openDetail(item),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.visitKind == 'PLAN'
                              ? Icons.list_alt_outlined
                              : Icons.outbox_outlined,
                          color: const Color(0xFF008DD2),
                        ),
                      ),
                      const SizedBox(width: 14),
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
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(item.displayDate),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.dealerName,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.areaName} - ${item.branchName}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.fullName,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(item.status)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                color: _statusColor(item.status),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}