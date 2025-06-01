import 'package:flutter/material.dart';
import 'package:tokopedia_clone/models/product.dart';

class Cart with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items => _items;

  void addItem(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.price);
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}