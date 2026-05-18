import 'package:flutter/material.dart';

import '../../data/models/area_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/services/master_service.dart';
import 'dealer_list_page.dart';

class BranchListPage extends StatefulWidget {
  final AreaModel area;

  const BranchListPage({
    super.key,
    required this.area,
  });

  @override
  State<BranchListPage> createState() => _BranchListPageState();
}

class _BranchListPageState extends State<BranchListPage> {
  final _masterService = MasterService();

  late Future<List<BranchModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _masterService.getBranches(areaId: widget.area.areaId);
  }

  void _refresh() {
    setState(() {
      _future = _masterService.getBranches(areaId: widget.area.areaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cabang - ${widget.area.areaName}'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<BranchModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Gagal mengambil data cabang',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text('Data cabang belum tersedia'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final branch = data[index];

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DealerListPage(branch: branch),
                      ),
                    );
                  },
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
                        const Icon(
                          Icons.apartment_outlined,
                          color: Color(0xFF263238),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            branch.branchName,
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
              );
            },
          );
        },
      ),
    );
  }
}