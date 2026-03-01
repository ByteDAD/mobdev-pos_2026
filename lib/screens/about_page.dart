import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFFECEFF8),
                child: Icon(Icons.person, size: 48, color: Color(0xFF8B93B3)),
              ),
              const SizedBox(height: 12),
              Text(
                'Nama Kamu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text('Mahasiswa Semester 4'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _InfoTile(label: 'Nama Panggilan', value: 'Panggilan'),
        _InfoTile(label: 'Hobi', value: 'Contoh: Ngoding, Musik'),
        _InfoTile(label: 'Media Sosial', value: '@username'),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    );
  }
}
