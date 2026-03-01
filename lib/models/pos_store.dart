import 'package:flutter/foundation.dart';

import 'product.dart';

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

  List<Product> get products => List.unmodifiable(_products);

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
  }) {
    _products.add(
      Product(
        id: _nextProductId++,
        name: name,
        price: price,
        stock: stock,
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

  Product? _findProduct(int id) {
    final index = _products.indexWhere((product) => product.id == id);
    if (index == -1) {
      return null;
    }
    return _products[index];
  }
}
