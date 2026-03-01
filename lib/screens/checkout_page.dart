import 'package:flutter/material.dart';

import '../models/pos_scope.dart';
import '../models/pos_store.dart';
import 'purchase_form_page.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context); // shared store
    final cartLines = store.cartLines;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Tambah Pembelian',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _openPurchaseForm(context), // open form
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              ),
            ],
          ),
        ),
        Expanded(
          child: cartLines.isEmpty
              ? _EmptyCheckoutState(onAdd: () => _openPurchaseForm(context))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartLines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final line = cartLines[index];
                    return _CartProductCard(
                      line: line,
                      onAdd: line.quantity < line.product.stock
                          ? () => store.incrementQty(line.product.id)
                          : null,
                      onRemove: line.quantity > 0
                          ? () => store.decrementQty(line.product.id)
                          : null,
                    );
                  },
                ),
        ),
        _CheckoutSummary(
          total: store.cartTotal,
          canCheckout: store.canCheckout,
          onCheckout: () => _handleCheckout(context),
        ),
      ],
    );
  }

  Future<void> _openPurchaseForm(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PurchaseFormPage()),
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    final store = PosScope.of(context);
    if (!store.canCheckout) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong atau stok kurang.')),
      );
      return;
    }

    final total = store.cartTotal;
    store.checkout(); // update stock

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaksi Berhasil'),
        content: Text('Total pembayaran: ${_formatRupiah(total)}'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCheckoutState extends StatelessWidget {
  const _EmptyCheckoutState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64),
            const SizedBox(height: 12),
            Text(
              'Belum ada item',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan item untuk mulai transaksi.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pembelian'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartProductCard extends StatelessWidget {
  const _CartProductCard({
    required this.line,
    required this.onAdd,
    required this.onRemove,
  });

  final CartLine line;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line.product.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Harga: ${_formatRupiah(line.product.price)}'),
            Text('Subtotal: ${_formatRupiah(line.subtotal)}'),
            Text('Stok: ${line.product.stock}'),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('Qty: ${line.quantity}'),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({
    required this.total,
    required this.canCheckout,
    required this.onCheckout,
  });

  final double total;
  final bool canCheckout;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Color(0x1A000000),
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Bayar'),
                const SizedBox(height: 4),
                Text(
                  _formatRupiah(total),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: canCheckout ? onCheckout : null,
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }
}

String _formatRupiah(double value) {
  final rounded = value.round();
  return 'Rp $rounded';
}
