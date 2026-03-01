import 'package:flutter/material.dart';

import '../models/pos_scope.dart';
import '../models/user_profile.dart';
import 'login_page.dart';
import 'profile_edit_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context); // auth state

    if (!store.isLoggedIn) {
      return _LoginRequired(onLogin: () => _openLogin(context));
    }

    final profile = store.profile;
    if (profile == null) {
      return const Center(child: Text('Profil belum tersedia.'));
    }

    return _ProfileView(profile: profile);
  }

  Future<void> _openLogin(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}

class _LoginRequired extends StatelessWidget {
  const _LoginRequired({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64),
            const SizedBox(height: 12),
            Text(
              'Login dulu ya',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Untuk melihat profil, silakan login terlebih dahulu.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              _ProfileAvatar(photoUrl: profile.photoUrl),
              const SizedBox(height: 12),
              Text(
                profile.fullName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text('@${profile.username}'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _InfoTile(label: 'Nama Panggilan', value: profile.nickname),
        _InfoTile(label: 'Hobi', value: profile.hobby.isEmpty ? '-' : profile.hobby),
        _InfoTile(
          label: 'Media Sosial',
          value: profile.social.isEmpty ? '-' : profile.social,
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => _openEdit(context),
          child: const Text('Edit Profil'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => store.logout(),
          child: const Text('Logout'),
        ),
      ],
    );
  }

  Future<void> _openEdit(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileEditPage(profile: profile)),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl.trim().isNotEmpty;
    if (!hasPhoto) {
      return const CircleAvatar(
        radius: 48,
        backgroundColor: Color(0xFFECEFF8),
        child: Icon(Icons.person, size: 48, color: Color(0xFF8B93B3)),
      );
    }
    return CircleAvatar(
      radius: 48,
      backgroundImage: NetworkImage(photoUrl),
      backgroundColor: const Color(0xFFECEFF8),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    );
  }
}
