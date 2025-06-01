import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokopedia_clone/models/product.dart';

class Transaction {
  final String id;
  final String userId;
  final List<Product> products;
  final double totalPrice;
  final String status;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.userId,
    required this.products,
    required this.totalPrice,
    required this.status,
    required this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json, String id) {
    return Transaction(
      id: id,
      userId: json['userId'],
      products: (json['products'] as List).map((item) => Product(
        id: item['id'],
        name: item['name'],
        price: item['price'].toDouble(),
        imageURL: item['imageURL'],
        rating: 0.0,
        soldCount: 0,
        location: '',
        tags: [],
      )).toList(),
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'products': products.map((product) => {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'imageURL': product.imageURL,
      }).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'timestamp': timestamp,
    };
  }
}