import 'package:flutter/material.dart';

import '../models/pos_scope.dart';
import '../models/user_profile.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _hobbyController;
  late final TextEditingController _socialController;
  late final TextEditingController _photoUrlController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _nicknameController = TextEditingController(text: widget.profile.nickname);
    _hobbyController = TextEditingController(text: widget.profile.hobby);
    _socialController = TextEditingController(text: widget.profile.social);
    _photoUrlController = TextEditingController(text: widget.profile.photoUrl);
    _photoUrlController.addListener(() {
      setState(() {}); // refresh preview
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _hobbyController.dispose();
    _socialController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: _ProfileImagePreview(url: _photoUrlController.text),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: 'Nama Panggilan'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hobbyController,
                decoration: const InputDecoration(labelText: 'Hobi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _socialController,
                decoration: const InputDecoration(labelText: 'Media Sosial'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(labelText: 'URL Foto Profil'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _save(context),
                child: const Text('Simpan'),
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
    final current = store.profile;
    if (current == null) {
      return;
    }
    final updated = current.copyWith(
      fullName: _fullNameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      hobby: _hobbyController.text.trim(),
      social: _socialController.text.trim(),
      photoUrl: _photoUrlController.text.trim(),
    );
    store.updateProfile(updated);
    Navigator.pop(context);
  }
}

class _ProfileImagePreview extends StatelessWidget {
  const _ProfileImagePreview({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.trim().isNotEmpty;
    if (!hasUrl) {
      return const CircleAvatar(
        radius: 44,
        backgroundColor: Color(0xFFECEFF8),
        child: Icon(Icons.person, size: 40, color: Color(0xFF8B93B3)),
      );
    }
    return CircleAvatar(
      radius: 44,
      backgroundColor: const Color(0xFFECEFF8),
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
      child: const Icon(Icons.person, color: Colors.transparent),
    );
  }
}
