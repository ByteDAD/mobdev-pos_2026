import 'package:flutter/material.dart';

import '../models/log_entry.dart';
import '../models/pos_scope.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final logs = store.logs;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: logs.isEmpty
          ? const Center(child: Text('Belum ada notifikasi.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = logs[index];
                return _NotificationCard(entry: log);
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(entry.timestamp);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: Text(entry.title),
        subtitle: Text(entry.detail),
        trailing: Text(time, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
