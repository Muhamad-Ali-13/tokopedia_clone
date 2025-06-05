import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tokopedia_clone/models/product.dart';
import 'dart:async';

class ProductService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedTag;
  final StreamController<List<Product>> _productsController = StreamController<List<Product>>.broadcast();

  ProductService() {
    print('ProductService initialized');
    fetchProducts();
  }

  String? get selectedTag => _selectedTag;
  Stream<List<Product>> get productsStream => _productsController.stream;

  void setSelectedTag(String? tag) {
    print('Setting selected tag to: $tag');
    _selectedTag = tag;
    fetchProducts();
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    print('Fetching products from Firestore...');
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('products').get();
      print('Fetched ${snapshot.docs.length} documents');
      if (snapshot.docs.isEmpty) {
        print('No products found in Firestore');
        _productsController.add([]);
        return;
      }
      final products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      print('Parsed products: ${products.map((p) => p.name).toList()}');
      _productsController.add(products);
    } catch (e, stackTrace) {
      print('Error fetching products: $e\nStackTrace: $stackTrace');
      _productsController.addError(e);
    }
  }

  @override
  void dispose() {
    print('Disposing ProductService');
    _productsController.close();
    super.dispose();
  }
}