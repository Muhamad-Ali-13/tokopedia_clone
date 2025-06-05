import 'package:flutter/material.dart';
import 'package:tokopedia_clone/models/product.dart';

class Wishlist with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  void addItem(Product product) {
    if (!_items.any((item) => item.id == product.id)) {
      _items.add(product);
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}