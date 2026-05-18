import 'package:flutter/material.dart';

import '../../data/models/master_item_model.dart';
import '../../data/services/master_service.dart';

class VisitPurposeListPage extends StatefulWidget {
  final MasterItemModel visitType;

  const VisitPurposeListPage({
    super.key,
    required this.visitType,
  });

  @override
  State<VisitPurposeListPage> createState() => _VisitPurposeListPageState();
}

class _VisitPurposeListPageState extends State<VisitPurposeListPage> {
  final _masterService = MasterService();

  late Future<List<MasterItemModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _masterService.getVisitPurposes(
      tipeVisitId: widget.visitType.id,
    );
  }

  void _refresh() {
    setState(() {
      _future = _masterService.getVisitPurposes(
        tipeVisitId: widget.visitType.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tujuan Visit - ${widget.visitType.name}'),
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
                  'Gagal mengambil data tujuan visit',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text('Data tujuan visit belum tersedia'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final purpose = data[index];

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEDEDED),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      color: Color(0xFF263238),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        purpose.name,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}