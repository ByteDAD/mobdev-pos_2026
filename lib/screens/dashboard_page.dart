import 'package:flutter/material.dart';

import '../models/pos_scope.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final totalProducts = store.products.length;
    final totalStock = store.products.fold<int>(0, (sum, p) => sum + p.stock);
    final totalValue = store.products.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.stock),
    );
    final zeroStock = store.products.where((p) => p.stock == 0).length;
    final lowStock =
        store.products.where((p) => p.stock > 0 && p.stock < 5).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.inventory_2_outlined,
                title: 'Total Produk',
                value: totalProducts.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.storefront,
                title: 'Total Stok',
                value: totalStock.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _WideStatCard(
          title: 'Nilai Stok',
          value: _formatRupiah(totalValue),
          subtitle: 'Estimasi nilai barang di gudang',
        ),
        const SizedBox(height: 20),
        Text(
          'Ringkasan',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _SummaryRow(label: 'Produk dengan stok 0', value: zeroStock.toString()),
        _SummaryRow(label: 'Produk stok < 5', value: lowStock.toString()),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _WideStatCard extends StatelessWidget {
  const _WideStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

String _formatRupiah(double value) {
  final rounded = value.round();
  return 'Rp $rounded';
}
