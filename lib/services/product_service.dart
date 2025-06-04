import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokopedia_clone/models/product.dart';
import 'dart:async';

class ProductService extends ChangeNotifier {
  final List<Product> _products = [];
  String? _selectedTag;
  final StreamController<List<Product>> _productController = StreamController<List<Product>>.broadcast();

  ProductService() {
    _fetchProducts();
  }

  Stream<List<Product>> get productsStream => _productController.stream;

  String? get selectedTag => _selectedTag;

  void setSelectedTag(String? tag) {
    _selectedTag = tag;
    _filterProducts();
    notifyListeners();
  }

  void _fetchProducts() {
    FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      _products.clear();
      for (var doc in snapshot.docs) {
        try {
          final product = Product(
            id: doc.id,
            name: doc['name'] as String? ?? 'Nama tidak tersedia',
            price: (doc['price'] as num?)?.toDouble() ?? 0.0,
            imageURL: (doc['imageURL'] as String?) ?? '',
            rating: (doc['rating'] as num?)?.toDouble() ?? 0.0,
            soldCount: (doc['soldCount'] as int?) ?? 0,
            location: (doc['location'] as String?) ?? '',
            tags: List<String>.from(doc['tags'] ?? []),
            discount: (doc['discount'] as num?)?.toDouble(),
          );
          _products.add(product);
        } catch (e) {
          print('Error mapping product ${doc.id}: $e');
        }
      }
      _filterProducts();
    }, onError: (error) {
      print('Error fetching products: $error');
    });
  }

  void _filterProducts() {
    final filteredProducts = _selectedTag == null
        ? List<Product>.from(_products)
        : _products.where((product) => product.tags.contains(_selectedTag)).toList();
    _productController.add(filteredProducts);
  }

  @override
  void dispose() {
    _productController.close();
    super.dispose();
  }
}