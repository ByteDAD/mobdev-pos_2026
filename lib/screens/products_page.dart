import 'package:flutter/material.dart';

import '../constants/product_options.dart';
import '../models/pos_scope.dart';
import '../models/product.dart';
import '../widgets/search_field.dart';
import 'product_form_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  String _query = '';
  late final TabController _tabController;
  String _categoryFilter = 'Semua';
  String _weightFilter = 'Semua';
  String _brandFilter = 'Semua';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // single tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final products = store.products
        .where((product) => product.name.toLowerCase().contains(_query))
        .where((product) =>
            _categoryFilter == 'Semua' ||
            product.category == _categoryFilter)
        .where((product) =>
            _weightFilter == 'Semua' ||
            product.weightCategory == _weightFilter)
        .where((product) =>
            _brandFilter == 'Semua' || product.brand == _brandFilter)
        .toList();

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Produk'),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SearchField(
            onChanged: (value) {
              setState(() {
                _query = value.trim().toLowerCase(); // filter text
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
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _categoryFilter,
                  items: ['Semua', ...ProductOptions.categories]
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
                      _categoryFilter = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _weightFilter,
                  items: ['Semua', ...ProductOptions.weightCategories]
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
                      _weightFilter = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Kategori Berat'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _brandFilter,
                  items: ['Semua', ...ProductOptions.brands]
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
                      _brandFilter = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Merk'),
                ),
              ],
            ),
          ),
          crossFadeState:
              _showFilters ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        Expanded(
          child: products.isEmpty
              ? _EmptyState(onAdd: () => _openProductForm(context))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(
                      product: product,
                      onEdit: () => _openProductForm(
                        context,
                        existing: product,
                      ),
                      onDelete: () => _confirmDelete(context, product),
                      onToggleFavorite: () =>
                          store.toggleFavorite(product.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openProductForm(
    BuildContext context, {
    Product? existing,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final store = PosScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text('Hapus ${product.name} dari daftar produk?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      store.removeProduct(product.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64),
            const SizedBox(height: 12),
            Text(
              'Belum ada produk',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan produk pertama untuk mulai mengelola stok.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Produk'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _ProductThumb(url: product.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text('Rp ${product.price.round()}'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Favorit',
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    product.isFavorite ? Icons.star : Icons.star_border,
                    color: product.isFavorite
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey,
                  ),
                ),
                Text(
                  'Stok: ${product.stock}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Hapus',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.trim().isNotEmpty;
    if (!hasUrl) {
      return Container(
        width: 48,
        height: 48,
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
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 48,
            height: 48,
            color: const Color(0xFFECEFF8),
            child: const Icon(Icons.broken_image, color: Color(0xFF8B93B3)),
          );
        },
      ),
    );
  }
}
