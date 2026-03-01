import 'package:flutter/foundation.dart';

import 'product.dart';
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
  final Map<int, int> _cart = {}; // cart items
  int _nextProductId = 1;
  bool _isLoggedIn = false;
  String? _registeredEmail;
  String? _registeredUsername;
  String? _registeredPassword;
  UserProfile? _profile;

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoggedIn => _isLoggedIn;
  UserProfile? get profile => _profile;

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
    notifyListeners();
  }

  void toggleFavorite(int productId) {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index == -1) {
      return;
    }
    final current = _products[index];
    _products[index] = current.copyWith(isFavorite: !current.isFavorite);
    notifyListeners();
  }

  void removeProduct(int id) {
    _products.removeWhere((product) => product.id == id);
    _cart.remove(id);
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
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void updateProfile(UserProfile updated) {
    _profile = updated;
    notifyListeners();
  }

  void checkout() {
    if (!canCheckout) {
      return;
    }
    for (final entry in _cart.entries) {
      final index = _products.indexWhere((product) => product.id == entry.key);
      if (index == -1) {
        continue;
      }
      final product = _products[index];
      _products[index] = product.copyWith(stock: product.stock - entry.value);
    }
    _cart.clear(); // reset cart
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
    notifyListeners();
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
}
