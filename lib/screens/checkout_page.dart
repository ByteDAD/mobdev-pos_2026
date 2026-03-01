import 'package:flutter/material.dart';

import '../models/pos_scope.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context); // shared store
    final products = store.products;
    final total = store.cartTotal;

    if (products.isEmpty) {
      return _EmptyCheckoutState(onNavigate: () {});
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              final qty = store.quantityFor(product.id);
              return _CartProductCard(
                name: product.name,
                price: product.price,
                stock: product.stock,
                quantity: qty,
                onAdd: product.stock > qty
                    ? () => store.incrementQty(product.id)
                    : null,
                onRemove: qty > 0 ? () => store.decrementQty(product.id) : null,
              );
            },
          ),
        ),
        _CheckoutSummary(
          total: total,
          canCheckout: store.canCheckout,
          onCheckout: () => _handleCheckout(context),
        ),
      ],
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
  const _EmptyCheckoutState({required this.onNavigate});

  final VoidCallback onNavigate;

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
              'Belum ada produk',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan produk terlebih dahulu sebelum kasir.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartProductCard extends StatelessWidget {
  const _CartProductCard({
    required this.name,
    required this.price,
    required this.stock,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final String name;
  final double price;
  final int stock;
  final int quantity;
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
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Harga: ${_formatRupiah(price)}'),
            Text('Stok: $stock'),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('Qty: $quantity'),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                if (stock == 0)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text('Stok habis'),
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
