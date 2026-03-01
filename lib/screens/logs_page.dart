import 'package:flutter/material.dart';

import '../models/pos_scope.dart';
import '../models/log_entry.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final logs = store.logs;

    return Scaffold(
      appBar: AppBar(title: const Text('Log')),
      body: logs.isEmpty
          ? const Center(child: Text('Belum ada aktivitas.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = logs[index];
                return _LogRow(entry: log);
              },
            ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(entry.timestamp);
    final time = _formatTime(entry.timestamp);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(date)),
            Expanded(flex: 1, child: Text(time)),
            Expanded(flex: 2, child: Text(entry.user)),
            Expanded(flex: 3, child: Text('${entry.title} ${entry.detail}')),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
