import 'package:flutter/material.dart';

import '../../common/widgets/bottom_nav.dart';
import '../../data/models/user_model.dart';
import '../../data/services/master_service.dart';
import '../home/home_page.dart';
import '../history/history_page.dart';
import 'area_list_page.dart';
import 'master_list_page.dart';
import 'visit_type_list_page.dart';

class MasterMenuPage extends StatelessWidget {
  final UserModel user;

  const MasterMenuPage({
    super.key,
    required this.user,
  });

  void _openMaster(
    BuildContext context, {
    required String title,
    required Future<List<String>> Function() loader,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MasterListPage(
          title: title,
          loader: loader,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = MasterService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Master'),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(user: user),
              ),
            );
            return;
          }

          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryPage(user: user),
              ),
            );
            return;
          }

          if (index == 2) {
            return;
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _menuItem(
            icon: Icons.person_outline,
            title: 'Jabatan Internal',
            onTap: () {
              _openMaster(
                context,
                title: 'Jabatan Internal',
                loader: () async {
                  final data = await service.getInternalPositions();
                  return data.map((e) => e.name).toList();
                },
              );
            },
          ),
          _menuItem(
            icon: Icons.location_on_outlined,
            title: 'Area',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AreaListPage(),
                ),
              );
            },
          ),
          _menuItem(
            icon: Icons.category_outlined,
            title: 'Produk',
            onTap: () {
              _openMaster(
                context,
                title: 'Produk',
                loader: () async {
                  final data = await service.getProducts();
                  return data.map((e) => e.name).toList();
                },
              );
            },
          ),
          _menuItem(
            icon: Icons.work_outline,
            title: 'Tipe Visit',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VisitTypeListPage(),
                ),
              );
            },
          ),
          _menuItem(
            icon: Icons.group_outlined,
            title: 'Jabatan Dealer',
            onTap: () {
              _openMaster(
                context,
                title: 'Jabatan Dealer',
                loader: () async {
                  final data = await service.getDealerPositions();
                  return data.map((e) => e.name).toList();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEDEDED),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF263238),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}