import 'package:flutter/material.dart';

import '../models/pos_scope.dart';
import '../models/purchase_order.dart';
import '../widgets/search_field.dart';
import 'purchase_detail_page.dart';
import 'purchase_form_page.dart';

class PurchaseOrdersPage extends StatefulWidget {
  const PurchaseOrdersPage({super.key});

  @override
  State<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends State<PurchaseOrdersPage> {
  String _query = '';
  bool _showFilters = false;
  String _statusFilter = 'Semua';
  String _supplierFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final orders = store.orders;
    final suppliers = {
      for (final order in orders) order.supplierName
    }.toList()..sort();

    final filtered = orders
        .where((order) =>
            order.code.toLowerCase().contains(_query) ||
            order.supplierName.toLowerCase().contains(_query))
        .where((order) =>
            _statusFilter == 'Semua' || order.status == _statusFilter)
        .where((order) =>
            _supplierFilter == 'Semua' ||
            order.supplierName == _supplierFilter)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pembelian')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchField(
              onChanged: (value) => setState(() {
                _query = value.trim().toLowerCase();
              }),
              onFilterTap: () => setState(() => _showFilters = !_showFilters),
              isFilterActive: _showFilters,
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _statusFilter,
                    items: const ['Semua', 'Diproses', 'Dikirim', 'Selesai']
                        .map(
                          (value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _statusFilter = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _supplierFilter,
                    items: ['Semua', ...suppliers]
                        .map(
                          (value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _supplierFilter = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Supplier'),
                  ),
                ],
              ),
            ),
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Belum ada pembelian.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return _OrderCard(order: order);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPurchaseForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openPurchaseForm(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PurchaseFormPage()),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final PurchaseOrder order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(order.code),
        subtitle: Text('${order.supplierName} • ${order.status}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_formatTime(order.createdAt)),
            Text(_formatDate(order.createdAt)),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PurchaseDetailPage(order: order),
          ),
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
