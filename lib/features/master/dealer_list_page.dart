import 'package:flutter/material.dart';

import '../../data/models/branch_model.dart';
import '../../data/models/dealer_model.dart';
import '../../data/services/master_service.dart';

class DealerListPage extends StatefulWidget {
  final BranchModel branch;

  const DealerListPage({
    super.key,
    required this.branch,
  });

  @override
  State<DealerListPage> createState() => _DealerListPageState();
}

class _DealerListPageState extends State<DealerListPage> {
  final _masterService = MasterService();

  late Future<List<DealerModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _masterService.getDealers(branchId: widget.branch.branchId);
  }

  void _refresh() {
    setState(() {
      _future = _masterService.getDealers(branchId: widget.branch.branchId);
    });
  }

  String _text(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dealer - ${widget.branch.branchName}'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<DealerModel>>(
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
                  'Gagal mengambil data dealer',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text('Data dealer belum tersedia'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final dealer = data[index];

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEDEDED),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.store_outlined,
                      color: Color(0xFF263238),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dealer.dealerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _text(dealer.address),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
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