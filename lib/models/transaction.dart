import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final double totalPrice;
  final double? subtotal;
  final double? shippingCost;
  final double? protectionFee;
  final double? insuranceFee;
  final double? codFee;
  final String? paymentOption;
  final String? status;
  final String? address;
  final String? trackingNumber;
  final DateTime timestamp;

  // WAJIB: Tambahkan items
  final List<Map<String, dynamic>>? items;

  Transaction({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.timestamp,
    this.subtotal,
    this.shippingCost,
    this.protectionFee,
    this.insuranceFee,
    this.codFee,
    this.paymentOption,
    this.status,
    this.address,
    this.trackingNumber,
    this.items,
  });

  factory Transaction.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Transaction(
      id: documentId,
      userId: data['userId'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      shippingCost: (data['shippingCost'] ?? 0).toDouble(),
      protectionFee: (data['protectionFee'] ?? 0).toDouble(),
      insuranceFee: (data['insuranceFee'] ?? 0).toDouble(),
      codFee: (data['codFee'] ?? 0).toDouble(),
      paymentOption: data['paymentOption'],
      status: data['status'],
      address: data['address'],
      trackingNumber: data['trackingNumber'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),

      // Parsing items
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
  }
}
