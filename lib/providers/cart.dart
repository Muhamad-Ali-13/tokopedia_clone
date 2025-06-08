import 'package:flutter/material.dart';
import 'package:tokopedia_clone/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Cart with ChangeNotifier {
  // Use Map for faster lookup by product ID
  final Map<String, CartItem> _items = {};
  final List<Product> _wishlist = [];

  // Getters
  List<CartItem> get items => _items.values.toList();
  List<Product> get wishlist => _wishlist;
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.values.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  // Add or update item in cart
  void addItem(Product product) {
    if (product.id == null) return;
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id!] = CartItem(product: product);
    }
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    final item = _items[productId]!;
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Wishlist toggle
  void toggleWishlist(Product product) {
    if (_wishlist.contains(product)) {
      _wishlist.remove(product);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  double get discountItems {
    // TODO: implement discount logic
    return 0;
  }

  double get discountShipping => 0;
}
