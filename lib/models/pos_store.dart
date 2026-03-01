import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'log_entry.dart';
import 'purchase_order.dart';
import 'product.dart';
import 'supplier.dart';
import 'user_profile.dart';

class CartLine {
  const CartLine({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;
}

class PosStore extends ChangeNotifier {
  final List<Product> _products = [];
  final List<Supplier> _suppliers = [];
  final List<LogEntry> _logs = [];
  final List<PurchaseOrder> _orders = [];
  final Map<int, int> _cart = {}; // cart items
  int _nextProductId = 1;
  int _nextSupplierId = 1;
  int _nextLogId = 1;
  int _nextOrderId = 1;
  bool _isLoggedIn = false;
  String? _registeredEmail;
  String? _registeredUsername;
  String? _registeredPassword;
  UserProfile? _profile;
  bool _notificationsEnabled = true;
  bool _showNotificationBadge = true;
  bool _lowStockAlert = true;

  PosStore() {
    _seedSuppliers();
  }

  List<Product> get products => List.unmodifiable(_products);
  List<Supplier> get suppliers => List.unmodifiable(_suppliers);
  List<LogEntry> get logs => List.unmodifiable(_logs);
  List<PurchaseOrder> get orders => List.unmodifiable(_orders);
  bool get isLoggedIn => _isLoggedIn;
  UserProfile? get profile => _profile;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get showNotificationBadge => _showNotificationBadge;
  bool get lowStockAlert => _lowStockAlert;

  List<CartLine> get cartLines {
    return _cart.entries
        .map((entry) => _findProduct(entry.key))
        .whereType<Product>()
        .map((product) => CartLine(
              product: product,
              quantity: _cart[product.id] ?? 0,
            ))
        .where((line) => line.quantity > 0)
        .toList(growable: false);
  }

  double get cartTotal {
    return cartLines.fold(0, (total, line) => total + line.subtotal);
  }

  bool get hasCartItems => _cart.values.any((qty) => qty > 0);

  int quantityFor(int productId) => _cart[productId] ?? 0;

  void addProduct({
    required String name,
    required double price,
    required int stock,
    String imageUrl = '',
    String category = '',
    String weightCategory = '',
    String brand = '',
    bool isFavorite = false,
  }) {
    _products.add(
      Product(
        id: _nextProductId++,
        name: name,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        category: category,
        weightCategory: weightCategory,
        brand: brand,
        isFavorite: isFavorite,
      ),
    );
    _addLog('Tambah Produk', name);
    notifyListeners();
  }

  void updateProduct(Product updated) {
    final index = _products.indexWhere((product) => product.id == updated.id);
    if (index == -1) {
      return;
    }
    _products[index] = updated;
    if ((_cart[updated.id] ?? 0) > updated.stock) {
      _cart[updated.id] = updated.stock; // clamp qty
    }
    _addLog('Ubah Produk', updated.name);
    notifyListeners();
  }

  void toggleFavorite(int productId) {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index == -1) {
      return;
    }
    final current = _products[index];
    _products[index] = current.copyWith(isFavorite: !current.isFavorite);
    _addLog('Favorit Produk', current.name);
    notifyListeners();
  }

  void removeProduct(int id) {
    final product = _findProduct(id);
    _products.removeWhere((product) => product.id == id);
    _cart.remove(id);
    if (product != null) {
      _addLog('Hapus Produk', product.name);
    }
    notifyListeners();
  }

  void addSupplier({
    required String name,
    required String contactPerson,
    required String email,
    required String phone,
    required String mobile,
    required String bankAccount,
    required String address,
    String imageUrl = '',
  }) {
    _suppliers.add(
      Supplier(
        id: _nextSupplierId++,
        name: name,
        contactPerson: contactPerson,
        email: email,
        phone: phone,
        mobile: mobile,
        bankAccount: bankAccount,
        address: address,
        imageUrl: imageUrl,
      ),
    );
    _addLog('Tambah Supplier', name);
    notifyListeners();
  }

  void updateSupplier(Supplier updated) {
    final index = _suppliers.indexWhere((supplier) => supplier.id == updated.id);
    if (index == -1) {
      return;
    }
    _suppliers[index] = updated;
    _addLog('Ubah Supplier', updated.name);
    notifyListeners();
  }

  void removeSupplier(int id) {
    final supplier = _suppliers.firstWhere(
      (s) => s.id == id,
      orElse: () => const Supplier(
        id: -1,
        name: '',
        contactPerson: '',
        email: '',
        phone: '',
        mobile: '',
        bankAccount: '',
        address: '',
        imageUrl: '',
      ),
    );
    _suppliers.removeWhere((supplier) => supplier.id == id);
    if (supplier.id != -1) {
      _addLog('Hapus Supplier', supplier.name);
    }
    notifyListeners();
  }

  void incrementQty(int productId) {
    final product = _findProduct(productId);
    if (product == null) {
      return;
    }
    final current = _cart[productId] ?? 0;
    if (current >= product.stock) {
      return;
    }
    _cart[productId] = current + 1;
    notifyListeners();
  }

  void decrementQty(int productId) {
    final current = _cart[productId] ?? 0;
    if (current <= 1) {
      _cart.remove(productId);
    } else {
      _cart[productId] = current - 1;
    }
    notifyListeners();
  }

  bool get canCheckout {
    if (!hasCartItems) {
      return false;
    }
    for (final entry in _cart.entries) {
      final product = _findProduct(entry.key);
      if (product == null || entry.value > product.stock) {
        return false;
      }
    }
    return true;
  }

  bool register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) {
    _registeredEmail = email.trim().toLowerCase();
    _registeredUsername = username.trim().toLowerCase();
    _registeredPassword = password;
    _profile = UserProfile(
      fullName: fullName.trim(),
      username: username.trim(),
      email: email.trim(),
      nickname: username.trim(),
      hobby: '',
      social: '',
      photoUrl: '',
    );
    _isLoggedIn = true; // auto login
    _addLog('Register', username.trim());
    notifyListeners();
    return true;
  }

  bool login({
    required String identity,
    required String password,
  }) {
    final normalized = identity.trim().toLowerCase();
    if (_registeredPassword == null) {
      return false;
    }
    final matchUser = normalized == _registeredUsername;
    final matchEmail = normalized == _registeredEmail;
    if ((matchUser || matchEmail) && password == _registeredPassword) {
      _isLoggedIn = true;
      _addLog('Login', normalized);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _addLog('Logout', _registeredUsername ?? '-');
    notifyListeners();
  }

  void updateProfile(UserProfile updated) {
    _profile = updated;
    _addLog('Update Profil', updated.fullName);
    notifyListeners();
  }

  void updateNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void updateShowNotificationBadge(bool value) {
    _showNotificationBadge = value;
    notifyListeners();
  }

  void updateLowStockAlert(bool value) {
    _lowStockAlert = value;
    notifyListeners();
  }

  void updateOrderStatus(int orderId, String status) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return;
    }
    _orders[index] = _orders[index].copyWith(status: status);
    _addLog('Update Status', '${_orders[index].code} $status');
    notifyListeners();
  }

  void createOrder({
    required int supplierId,
    required Map<int, int> items,
    TimeOfDay? time,
    DateTime? date,
  }) {
    if (items.isEmpty) {
      return;
    }
    final supplier =
        _suppliers.firstWhere((s) => s.id == supplierId, orElse: () => _suppliers.first);
    final createdAt = _mergeDateTime(date, time);
    final lines = items.entries
        .map((entry) => _findProduct(entry.key))
        .whereType<Product>()
        .map(
          (product) => PurchaseLine(
            productId: product.id,
            productName: product.name,
            unitPrice: product.price,
            quantity: items[product.id] ?? 0,
          ),
        )
        .where((line) => line.quantity > 0)
        .toList();

    final order = PurchaseOrder(
      id: _nextOrderId++,
      code: 'PO-${_nextOrderId.toString().padLeft(3, '0')}',
      supplierId: supplier.id,
      supplierName: supplier.name,
      user: _profile?.username ?? _registeredUsername ?? 'user',
      createdAt: createdAt,
      status: 'Diproses',
      lines: lines,
    );
    _orders.insert(0, order);
    _addLog('Tambah Pembelian', order.code);
    notifyListeners();
  }

  void checkout() {
    if (!canCheckout) {
      return;
    }
    final total = cartTotal;
    for (final entry in _cart.entries) {
      final index = _products.indexWhere((product) => product.id == entry.key);
      if (index == -1) {
        continue;
      }
      final product = _products[index];
      _products[index] = product.copyWith(stock: product.stock - entry.value);
    }
    _cart.clear(); // reset cart
    _addLog('Checkout', 'Total ${total.toStringAsFixed(0)}');
    notifyListeners();
  }

  void setCart(Map<int, int> quantities) {
    _cart.clear(); // replace cart
    for (final entry in quantities.entries) {
      final product = _findProduct(entry.key);
      if (product == null) {
        continue;
      }
      final clamped = entry.value.clamp(0, product.stock);
      if (clamped > 0) {
        _cart[product.id] = clamped;
      }
    }
    if (_cart.isNotEmpty) {
      _addLog('Draft Pembelian', 'Item ${_cart.length}');
    }
    notifyListeners();
  }

  DateTime _mergeDateTime(DateTime? date, TimeOfDay? time) {
    final now = DateTime.now();
    final base = date ?? now;
    if (time == null) {
      return DateTime(base.year, base.month, base.day, now.hour, now.minute);
    }
    return DateTime(base.year, base.month, base.day, time.hour, time.minute);
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Product? _findProduct(int id) {
    final index = _products.indexWhere((product) => product.id == id);
    if (index == -1) {
      return null;
    }
    return _products[index];
  }

  void _seedSuppliers() {
    if (_suppliers.isNotEmpty) {
      return;
    }
    addSupplier(
      name: 'Unilever',
      contactPerson: 'kontak C',
      email: 'unilever@gmail.com',
      phone: '0812333333',
      mobile: '0812333333',
      bankAccount: '1234567890',
      address: 'Jl. Merdeka No. 10',
    );
    addSupplier(
      name: 'Wings',
      contactPerson: 'kontak B',
      email: 'iwings@gmail.com',
      phone: '0812333333',
      mobile: '0812333333',
      bankAccount: '1234567890',
      address: 'Jl. Asia Afrika No. 5',
    );
    addSupplier(
      name: 'Indofood',
      contactPerson: 'kontak A',
      email: 'indofood@gmail.com',
      phone: '0812333333',
      mobile: '0812333333',
      bankAccount: '1234567890',
      address: 'Jl. Kalimantan No. 7',
    );
  }

  void _addLog(String title, String detail) {
    final user = _profile?.username ?? _registeredUsername ?? 'system';
    _logs.insert(
      0,
      LogEntry(
        id: _nextLogId++,
        title: title,
        detail: detail,
        user: user,
        timestamp: DateTime.now(),
      ),
    );
  }
}
