import 'package:flutter/foundation.dart';

import 'product.dart';

class PosStore extends ChangeNotifier {
  final List<Product> _products = [];
  int _nextProductId = 1;

  List<Product> get products => List.unmodifiable(_products);

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
    notifyListeners();
  }

  void removeProduct(int id) {
    _products.removeWhere((product) => product.id == id);
    notifyListeners();
  }
}
