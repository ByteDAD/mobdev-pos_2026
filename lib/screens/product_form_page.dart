import 'package:flutter/material.dart';

import '../constants/product_options.dart';
import '../models/pos_scope.dart';
import '../models/product.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.existing});

  final Product? existing;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>(); // form key
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;
  late String _category;
  late String _weightCategory;
  late String _brand;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _priceController = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.price.toStringAsFixed(0)
          : '',
    );
    _stockController = TextEditingController(
      text: widget.existing != null ? widget.existing!.stock.toString() : '',
    );
    _imageUrlController = TextEditingController(
      text: widget.existing?.imageUrl ?? '',
    );
    _imageUrlController.addListener(() {
      setState(() {}); // preview update
    });
    _category = widget.existing?.category.isNotEmpty == true
        ? widget.existing!.category
        : ProductOptions.categories.first;
    _weightCategory = widget.existing?.weightCategory.isNotEmpty == true
        ? widget.existing!.weightCategory
        : ProductOptions.weightCategories.first;
    _brand = widget.existing?.brand.isNotEmpty == true
        ? widget.existing!.brand
        : ProductOptions.brands.first;
    _isFavorite = widget.existing?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Produk' : 'Tambah Produk'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                isEdit ? 'Detail Produk' : 'Tambah Produk',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _ImagePreview(url: _imageUrlController.text),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Gambar Produk'),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: ProductOptions.categories
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
                    _category = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _weightCategory,
                items: ProductOptions.weightCategories
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
                    _weightCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Kategori Berat'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _brand,
                items: ProductOptions.brands
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
                    _brand = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Merk'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama produk wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Stok harus 0 atau lebih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tambahkan ke favorit'),
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _save(context),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final store = PosScope.of(context); // store access
    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final stock = int.parse(_stockController.text.trim());
    final imageUrl = _imageUrlController.text.trim();

    if (widget.existing == null) {
      store.addProduct(
        name: name,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        category: _category,
        weightCategory: _weightCategory,
        brand: _brand,
        isFavorite: _isFavorite,
      );
    } else {
      store.updateProduct(
        widget.existing!.copyWith(
          name: name,
          price: price,
          stock: stock,
          imageUrl: imageUrl,
          category: _category,
          weightCategory: _weightCategory,
          brand: _brand,
          isFavorite: _isFavorite,
        ),
      );
    }

    Navigator.pop(context);
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.trim().isNotEmpty;
    if (!hasUrl) {
      return Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: const Color(0xFFECEFF8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.image,
          size: 42,
          color: Color(0xFF8B93B3),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        url,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 96,
            height: 96,
            color: const Color(0xFFECEFF8),
            child: const Icon(Icons.broken_image, color: Color(0xFF8B93B3)),
          );
        },
      ),
    );
  }
}
