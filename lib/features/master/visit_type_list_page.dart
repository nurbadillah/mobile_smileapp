import 'package:flutter/material.dart';

import '../../data/models/master_item_model.dart';
import '../../data/services/master_service.dart';
import 'visit_purpose_list_page.dart';

class VisitTypeListPage extends StatefulWidget {
  const VisitTypeListPage({super.key});

  @override
  State<VisitTypeListPage> createState() => _VisitTypeListPageState();
}

class _VisitTypeListPageState extends State<VisitTypeListPage> {
  final _masterService = MasterService();

  late Future<List<MasterItemModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _masterService.getVisitTypes();
  }

  void _refresh() {
    setState(() {
      _future = _masterService.getVisitTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipe Visit'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<MasterItemModel>>(
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
                  'Gagal mengambil data tipe visit',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text('Data tipe visit belum tersedia'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final visitType = data[index];

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VisitPurposeListPage(
                          visitType: visitType,
                        ),
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
                          Icons.work_outline,
                          color: Color(0xFF263238),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            visitType.name,
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