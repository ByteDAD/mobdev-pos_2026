import 'package:flutter/material.dart';

import '../models/pos_scope.dart';
import '../models/product.dart';
import 'suppliers_page.dart';

class PurchaseFormPage extends StatefulWidget {
  const PurchaseFormPage({super.key});

  @override
  State<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends State<PurchaseFormPage> {
  TimeOfDay? _time;
  DateTime? _date;
  final List<_PurchaseLine> _lines = [
    _PurchaseLine(),
  ];
  int? _supplierId;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final products = store.products;
    final suppliers = store.suppliers;

    if (products.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tambah Pembelian')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Tambahkan produk terlebih dahulu.'),
          ),
        ),
      );
    }
    if (suppliers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tambah Pembelian')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tambahkan supplier terlebih dahulu.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _openSuppliers(context),
                  child: const Text('Tambah Supplier'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pembelian')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<int>(
              value: _supplierId,
              items: suppliers
                  .map(
                    (supplier) => DropdownMenuItem<int>(
                      value: supplier.id,
                      child: Text(supplier.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _supplierId = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Pilih Supplier'),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _openSuppliers(context),
                child: const Text('Edit Supplier'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(context),
                    icon: const Icon(Icons.access_time),
                    label: Text(_time == null ? 'Waktu pesan' : _formatTime(_time!)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_date == null ? 'Tanggal pesan' : _formatDate(_date!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Produk', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._buildLineItems(products),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  setState(() {
                    _lines.add(_PurchaseLine()); // add line
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Item'),
              ),
            ),
            const SizedBox(height: 20),
            _TotalSummary(total: _computeTotal(products)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _save(context, products),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLineItems(List<Product> products) {
    return List.generate(_lines.length, (index) {
      final line = _lines[index];
      final selectedProduct = line.productId == null
          ? null
          : products.firstWhere(
              (product) => product.id == line.productId,
              orElse: () => products.first,
            );
      final subtotal = selectedProduct == null
          ? 0.0
          : selectedProduct.price * line.quantity;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: line.productId,
                decoration: const InputDecoration(labelText: 'Pilih Produk'),
                items: products
                    .map(
                      (product) => DropdownMenuItem<int>(
                        value: product.id,
                        child: Text(product.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    line.productId = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: line.quantity > 1
                        ? () {
                            setState(() {
                              line.quantity--; // reduce qty
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('Qty: ${line.quantity}'),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        line.quantity++;
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  const Spacer(),
                  Text('Subtotal: ${_formatRupiah(subtotal)}'),
                ],
              ),
              if (_lines.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _lines.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Hapus'),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  double _computeTotal(List<Product> products) {
    double total = 0;
    for (final line in _lines) {
      final product = line.productId == null
          ? null
          : products.firstWhere(
              (item) => item.id == line.productId,
              orElse: () => products.first,
            );
      if (product != null) {
        total += product.price * line.quantity;
      }
    }
    return total;
  }

  Future<void> _pickTime(BuildContext context) async {
    final result = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (result == null) {
      return;
    }
    setState(() {
      _time = result;
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (result == null) {
      return;
    }
    setState(() {
      _date = result;
    });
  }

  void _save(BuildContext context, List<Product> products) {
    if (_supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih supplier terlebih dahulu.')),
      );
      return;
    }
    final cart = <int, int>{};

    for (final line in _lines) {
      if (line.productId == null) {
        continue;
      }
      final product = products.firstWhere(
        (item) => item.id == line.productId,
        orElse: () => products.first,
      );
      final quantity = line.quantity;
      if (quantity <= 0) {
        continue;
      }
      if (quantity > product.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stok ${product.name} tidak cukup.')),
        );
        return;
      }
      final existing = cart[product.id] ?? 0;
      cart[product.id] = existing + quantity; // merge qty
    }

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu.')),
      );
      return;
    }

    final store = PosScope.of(context);
    store.createOrder(
      supplierId: _supplierId!,
      items: cart,
      time: _time,
      date: _date,
    );
    Navigator.pop(context);
  }

  Future<void> _openSuppliers(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SuppliersPage()),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _PurchaseLine {
  int? productId;
  int quantity = 1;
}

class _TotalSummary extends StatelessWidget {
  const _TotalSummary({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('Total'),
            const Spacer(),
            Text(
              _formatRupiah(total),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRupiah(double value) {
  final rounded = value.round();
  return 'Rp $rounded';
}
