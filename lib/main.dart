import 'package:flutter/material.dart';

import 'models/pos_scope.dart';
import 'models/pos_store.dart';
import 'screens/about_page.dart';
import 'screens/checkout_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/login_page.dart';
import 'screens/products_page.dart';
import 'theme.dart';
import 'widgets/shonk_logo.dart';

void main() {
  runApp(const PosApp());
}

class PosApp extends StatefulWidget {
  const PosApp({super.key});

  @override
  State<PosApp> createState() => _PosAppState();
}

class _PosAppState extends State<PosApp> {
  late final PosStore _store;

  @override
  void initState() {
    super.initState();
    _store = PosStore();
  }

  @override
  Widget build(BuildContext context) {
    return PosScope(
      store: _store,
      child: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          return MaterialApp(
            title: 'Simple POS',
            theme: AppTheme.theme(),
            home: _store.isLoggedIn ? const HomeShell() : const LoginPage(),
          );
        },
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ProductsPage(),
    CheckoutPage(),
    AboutPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            );
          },
        ),
        title: Text(_titleForIndex(_currentIndex)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      drawer: _AppDrawer(
        currentIndex: _currentIndex,
        onSelect: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tentang',
          ),
        ],
      ),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Kelola Produk';
      case 2:
        return 'Pembelian';
      case 3:
        return 'Tentang Saya';
      default:
        return 'Simple POS';
    }
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final profile = store.profile;
    final displayName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (profile?.username ?? 'User');

    return Drawer(
      backgroundColor: const Color(0xFF32335A),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const ShonkLogo(
              iconSize: 46,
              titleSize: 20,
              showSubtitle: false,
              primaryColor: Colors.white,
              subtitleColor: Colors.white70,
            ),
            const SizedBox(height: 12),
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFF50548C),
              child: Icon(Icons.person, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            const Text(
              'Purchasing',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              displayName,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            _DrawerItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              selected: currentIndex == 0,
              onTap: () => _select(context, 0),
            ),
            _DrawerItem(
              icon: Icons.inventory_2_outlined,
              label: 'Produk',
              selected: currentIndex == 1,
              onTap: () => _select(context, 1),
            ),
            _DrawerItem(
              icon: Icons.shopping_cart_outlined,
              label: 'Pembelian',
              selected: currentIndex == 2,
              onTap: () => _select(context, 2),
            ),
            _DrawerItem(
              icon: Icons.group_outlined,
              label: 'Supplier',
              selected: false,
              onTap: () => _showPlaceholder(context, 'Supplier'),
            ),
            _DrawerItem(
              icon: Icons.receipt_long_outlined,
              label: 'Log',
              selected: false,
              onTap: () => _showPlaceholder(context, 'Log'),
            ),
            const Divider(color: Colors.white30, height: 24),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Pengaturan',
              selected: false,
              onTap: () => _showPlaceholder(context, 'Pengaturan'),
            ),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Logout',
              selected: false,
              onTap: () {
                store.logout();
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            const Text(
              'Version 1.0',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _select(BuildContext context, int index) {
    onSelect(index);
    Navigator.pop(context);
  }

  void _showPlaceholder(BuildContext context, String label) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label belum dibuat.')),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      selected: selected,
      selectedTileColor: const Color(0xFFE57C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
