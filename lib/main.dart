import 'package:flutter/material.dart';

import 'models/pos_scope.dart';
import 'models/pos_store.dart';
import 'screens/about_page.dart';
import 'screens/checkout_page.dart';
import 'screens/products_page.dart';
import 'theme.dart';

void main() {
  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple POS',
      theme: AppTheme.theme(),
      home: const HomeShell(),
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
  late final PosStore _store;

  final List<Widget> _pages = const [
    ProductsPage(),
    CheckoutPage(),
    AboutPage(),
  ];

  @override
  void initState() {
    super.initState();
    _store = PosStore();
  }

  @override
  Widget build(BuildContext context) {
    return PosScope(
      store: _store,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
          title: Text(_titleForIndex(_currentIndex)),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications),
            ),
          ],
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
      ),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Kelola Produk';
      case 1:
        return 'Pembelian';
      case 2:
        return 'Tentang Saya';
      default:
        return 'Simple POS';
    }
  }
}
