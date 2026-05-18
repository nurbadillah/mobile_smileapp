import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/widgets/bottom_nav.dart';
import '../../data/models/history_list_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/visit_summary_model.dart';
import '../../data/services/history_service.dart';
import '../auth/login_page.dart';
import '../history/history_detail_page.dart';
import '../history/history_page.dart';
import '../master/master_menu_page.dart';
import '../visit/direct_visit_option_page.dart';
import '../visit/plan_visit_page.dart';

class HomePage extends StatelessWidget {
  final UserModel user;
  final HistoryService _historyService = HistoryService();

  HomePage({
    super.key,
    required this.user,
  });

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            return;
          }

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryPage(user: user),
              ),
            );
            return;
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MasterMenuPage(user: user),
              ),
            );
            return;
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF232ACB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_outline,
                      size: 42,
                      color: Color(0xFF232ACB),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          user.internalPositionName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _logout(context),
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            _visitSummaryCard(),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: _menuCard(
                      icon: Icons.outbox_outlined,
                      title: 'Direct Visit',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DirectVisitOptionPage(user: user),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 34),
                  Expanded(
                    child: _menuCard(
                      icon: Icons.list_alt_outlined,
                      title: 'Plan Visit',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlanVisitPage(user: user),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: _historyCard(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visitSummaryCard() {
    return FutureBuilder<VisitSummaryModel>(
      future: _historyService.getSummary(),
      builder: (context, snapshot) {
        final summary = snapshot.data;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Kunjungan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _summaryItem(
                      icon: Icons.calendar_month_outlined,
                      value: snapshot.connectionState == ConnectionState.waiting
                          ? '-'
                          : '${summary?.totalVisit ?? 0}',
                      title: 'Total Kunjungan',
                      subtitle: '(Bulan Ini)',
                      backgroundColor: const Color(0xFFEAF4FF),
                      iconColor: const Color(0xFF2F80ED),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryItem(
                      icon: Icons.event_available_outlined,
                      value: snapshot.connectionState == ConnectionState.waiting
                          ? '-'
                          : '${summary?.planVisit ?? 0}',
                      title: 'Plan Visit',
                      subtitle: '(Bulan Ini)',
                      backgroundColor: const Color(0xFFEAF8EF),
                      iconColor: const Color(0xFF27AE60),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryItem(
                      icon: Icons.near_me_outlined,
                      value: snapshot.connectionState == ConnectionState.waiting
                          ? '-'
                          : '${summary?.directVisit ?? 0}',
                      title: 'Direct Visit',
                      subtitle: '(Bulan Ini)',
                      backgroundColor: const Color(0xFFF1EAFE),
                      iconColor: const Color(0xFF9B51E0),
                    ),
                  ),
                ],
              ),
              if (snapshot.hasError) ...[
                const SizedBox(height: 8),
                const Text(
                  'Gagal mengambil ringkasan kunjungan',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String value,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF555555),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'History',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF24445C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryPage(user: user),
                    ),
                  );
                },
                child: const Text('More history...'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<HistoryListModel>>(
              future: _historyService.getHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Gagal mengambil history',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final histories = snapshot.data ?? [];
                final latestHistories = histories.take(5).toList();

                if (latestHistories.isEmpty) {
                  return const Center(
                    child: Text('History belum tersedia'),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: latestHistories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = latestHistories[index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HistoryDetailPage(
                              visitId: item.visitId,
                              user: user,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFEDEDED),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.visitKind == 'PLAN'
                                  ? Icons.list_alt_outlined
                                  : Icons.outbox_outlined,
                              color: const Color(0xFF008DD2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatHistoryDate(item.displayDate),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.dealerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatHistoryDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    return DateFormat('dd-MM-yyyy').format(date);
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF008DD2), size: 34),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}