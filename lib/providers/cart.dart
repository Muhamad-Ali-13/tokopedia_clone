import 'package:flutter/material.dart';
import 'package:tokopedia_clone/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Cart with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  void addItem(Product product) {
    final CartItem? existingItem = _items.where((item) => item.product.id == product.id).isNotEmpty
        ? _items.firstWhere((item) => item.product.id == product.id)
        : null;
    if (existingItem != null) {
      existingItem.quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    final item = _items.firstWhere((item) => item.product.id == productId);
    item.quantity++;
    notifyListeners();
  }

  void decrementQuantity(String productId) {
    final item = _items.firstWhere((item) => item.product.id == productId);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.removeWhere((item) => item.product.id == productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
class cart with ChangeNotifier {
  final Map<String, Product> _items = {};

  Map<String, Product> get items => _items;

  void addItem(Product product) {
    _items[product.id] = product;
    notifyListeners();
  }
}