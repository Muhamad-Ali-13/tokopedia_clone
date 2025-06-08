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
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null || data['name'] == null || data['price'] == null) {
                print('Skipping invalid document ID: ${doc.id}, data: $data');
                return null;
              }
              final product = Product.fromJson(data as Map<String, dynamic>, doc.id);
              if (product.id != null && product.name != null && product.price != null) {
                return product;
              } else {
                print('Invalid product data for doc ID: ${doc.id}, product: $product');
                return null;
              }
            } catch (e) {
              print('Error parsing product for doc ID: ${doc.id}, error: $e');
              return null;
            }
          })
          .where((product) => product != null)
          .cast<Product>()
          .toList();
      print('Parsed valid products: ${products.map((p) => p.name).toList()}');
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