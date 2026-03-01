import 'package:flutter/material.dart';

import '../models/pos_scope.dart';
import '../models/supplier.dart';
import '../widgets/search_field.dart';
import 'supplier_form_page.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  String _query = '';
  bool _showFilters = false;
  String _contactFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final contacts = {
      for (final supplier in store.suppliers) supplier.contactPerson
    }.where((value) => value.trim().isNotEmpty).toList()
      ..sort();
    final suppliers = store.suppliers
        .where((supplier) => supplier.name.toLowerCase().contains(_query))
        .where((supplier) =>
            _contactFilter == 'Semua' ||
            supplier.contactPerson == _contactFilter)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Supplier')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchField(
              onChanged: (value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
              onFilterTap: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              isFilterActive: _showFilters,
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: DropdownButtonFormField<String>(
                value: _contactFilter,
                items: ['Semua', ...contacts]
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
                    _contactFilter = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Contact Person'),
              ),
            ),
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          Expanded(
            child: suppliers.isEmpty
                ? const Center(child: Text('Belum ada supplier.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: suppliers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final supplier = suppliers[index];
                      return _SupplierCard(
                        supplier: supplier,
                        onEdit: () => _openForm(context, supplier),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, Supplier? supplier) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SupplierFormPage(existing: supplier)),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  const _SupplierCard({required this.supplier, required this.onEdit});

  final Supplier supplier;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _SupplierThumb(url: supplier.imageUrl),
        title: Text(supplier.name),
        subtitle: Text(supplier.contactPerson),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              supplier.email,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              supplier.phone,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}

class _SupplierThumb extends StatelessWidget {
  const _SupplierThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.trim().isNotEmpty;
    if (!hasUrl) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFECEFF8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image, color: Color(0xFF8B93B3)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 42,
            height: 42,
            color: const Color(0xFFECEFF8),
            child: const Icon(Icons.broken_image, color: Color(0xFF8B93B3)),
          );
        },
      ),
    );
  }
}
