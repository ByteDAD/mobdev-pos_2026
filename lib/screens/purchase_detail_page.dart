import 'package:flutter/material.dart';

import '../models/pos_scope.dart';
import '../models/purchase_order.dart';

class PurchaseDetailPage extends StatefulWidget {
  const PurchaseDetailPage({super.key, required this.order});

  final PurchaseOrder order;

  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  late PurchaseOrder _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pembelian')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: 'No Order', value: _order.code),
                  _InfoRow(label: 'Nama supplier', value: _order.supplierName),
                  _InfoRow(label: 'Waktu', value: _formatTime(_order.createdAt)),
                  _InfoRow(
                    label: 'Tanggal pesan',
                    value: _formatDate(_order.createdAt),
                  ),
                  _InfoRow(label: 'User', value: _order.user),
                  _StatusRow(
                    value: _order.status,
                    onChanged: (value) => _updateStatus(context, value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Produk yang dipesan'),
                  const SizedBox(height: 12),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(2.2),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.5),
                    },
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF3F4F6)),
                        children: [
                          _HeaderCell('Kode'),
                          _HeaderCell('Nama'),
                          _HeaderCell('Harga'),
                          _HeaderCell('Qty'),
                          _HeaderCell('Subtotal'),
                        ],
                      ),
                      ..._order.lines.map(
                        (line) => TableRow(
                          children: [
                            _Cell(_productCode(line.productId)),
                            _Cell(line.productName),
                            _Cell('Rp ${line.unitPrice.round()}'),
                            _Cell(line.quantity.toString()),
                            _Cell('Rp ${line.subtotal.round()}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton(
              onPressed: () {},
              child: const Text('Print'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _productCode(int id) => 'P-${id.toString().padLeft(3, '0')}';

  void _updateStatus(BuildContext context, String status) {
    final store = PosScope.of(context);
    store.updateOrderStatus(_order.id, status);
    setState(() {
      _order = _order.copyWith(status: status);
    });
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Expanded(child: Text('Status pembelian')),
          DropdownButton<String>(
            value: value,
            items: const ['Diproses', 'Dikirim', 'Selesai']
                .map(
                  (status) => DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
