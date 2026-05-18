import 'package:flutter/material.dart';

class MasterListPage extends StatefulWidget {
  final String title;
  final Future<List<String>> Function() loader;

  const MasterListPage({
    super.key,
    required this.title,
    required this.loader,
  });

  @override
  State<MasterListPage> createState() => _MasterListPageState();
}

class _MasterListPageState extends State<MasterListPage> {
  late Future<List<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  void _refresh() {
    setState(() {
      _future = widget.loader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Refresh',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal mengambil data.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text('Data belum tersedia'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_copy_outlined),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        data[index],
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