import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/models/transaction.dart';
import 'package:tokopedia_clone/providers/auth.dart';
import 'package:tokopedia_clone/utils/utils.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'Silakan login terlebih dahulu',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.mainThemeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Utils.mainThemeColor,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: authService.currentUser!.uid)
            .orderBy('timestamp', descending: true) // Urutkan berdasarkan waktu terbaru
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error fetching transactions: ${snapshot.error}'); // Log error untuk debugging
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 40, color: Colors.red),
                  SizedBox(height: 10),
                  Text(
                    'Terjadi kesalahan: ${snapshot.error.toString().split('\n').first}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Utils.mainThemeColor));
          }
          final data = snapshot.data;
          if (data == null || data.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 40, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Tidak ada riwayat transaksi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final transactions = data.docs
              .map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  return Transaction(
                    id: doc.id,
                    userId: data['userId'] as String? ?? '',
                    items: List<Map<String, dynamic>>.from(data['items'] ?? []),
                    totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
                    status: data['status'] as String? ?? 'Unknown',
                    timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  );
                } catch (e) {
                  print('Error mapping transaction ${doc.id}: $e');
                  return Transaction(
                    id: doc.id,
                    userId: '',
                    items: [],
                    totalPrice: 0.0,
                    status: 'Error',
                    timestamp: DateTime.now(),
                  );
                }
              })
              .toList();

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: _getStatusIcon(transaction.status),
                  title: Text(
                    'Transaksi #${transaction.id.substring(0, 8)}...', // Potong ID untuk ringkas
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        'Total: Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 14, color: Utils.mainThemeColor),
                      ),
                      Text(
                        'Tanggal: ${DateFormat('dd MMM yyyy').format(transaction.timestamp)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/transaction_detail',
                        arguments: transaction,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Utils.mainThemeColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      'Lihat Detail',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Fungsi untuk mendapatkan ikon berdasarkan status
  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'dibayar':
        return Icon(Icons.payment, color: Utils.mainThemeColor, size: 30);
      case 'diproses':
        return Icon(Icons.hourglass_empty, color: Utils.mainThemeColor, size: 30);
      case 'dikirim':
        return Icon(Icons.local_shipping, color: Utils.mainThemeColor, size: 30);
      case 'selesai':
        return Icon(Icons.check_circle, color: Utils.mainThemeColor, size: 30);
      case 'dibatalkan':
        return Icon(Icons.cancel, color: Colors.red, size: 30);
      default:
        return Icon(Icons.help_outline, color: Colors.grey, size: 30);
    }
  }
}