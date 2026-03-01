import 'package:flutter/material.dart';

import '../models/pos_scope.dart';
import '../models/supplier.dart';

class SupplierFormPage extends StatefulWidget {
  const SupplierFormPage({super.key, this.existing});

  final Supplier? existing;

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _mobileController;
  late final TextEditingController _bankController;
  late final TextEditingController _addressController;
  late final TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameController = TextEditingController(text: s?.name ?? '');
    _contactController = TextEditingController(text: s?.contactPerson ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _mobileController = TextEditingController(text: s?.mobile ?? '');
    _bankController = TextEditingController(text: s?.bankAccount ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _imageUrlController = TextEditingController(text: s?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _bankController.dispose();
    _addressController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Detail Supplier' : 'Tambah Supplier'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: _SupplierImagePreview(url: _imageUrlController.text),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Supplier'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact person'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'No telephone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'No handphone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bankController,
                decoration: const InputDecoration(labelText: 'No rekening'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Foto'),
                keyboardType: TextInputType.url,
              ),
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
    final store = PosScope.of(context);
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final mobile = _mobileController.text.trim();
    final bank = _bankController.text.trim();
    final address = _addressController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (widget.existing == null) {
      store.addSupplier(
        name: name,
        contactPerson: contact,
        email: email,
        phone: phone,
        mobile: mobile,
        bankAccount: bank,
        address: address,
        imageUrl: imageUrl,
      );
    } else {
      store.updateSupplier(
        widget.existing!.copyWith(
          name: name,
          contactPerson: contact,
          email: email,
          phone: phone,
          mobile: mobile,
          bankAccount: bank,
          address: address,
          imageUrl: imageUrl,
        ),
      );
    }

    Navigator.pop(context);
  }
}

class _SupplierImagePreview extends StatelessWidget {
  const _SupplierImagePreview({required this.url});

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
        child: const Icon(Icons.image, color: Color(0xFF8B93B3)),
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
