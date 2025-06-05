import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final String status;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.timestamp,
  });

  factory Transaction.fromFirestore(Map<String, dynamic> data, String id) {
    print('Parsing transaction with ID: $id, Data: $data');
    return Transaction(
      id: id,
      userId: data['userId'] as String? ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'Unknown',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items,
      'totalPrice': totalPrice,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}