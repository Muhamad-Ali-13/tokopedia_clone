import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/models/transaction.dart';
import 'package:tokopedia_clone/providers/auth.dart';
import 'package:tokopedia_clone/utils/utils.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.currentUser == null) {
      print('No authenticated user found');
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

    print('Authenticated userId: ${authService.currentUser!.uid}');

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
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error fetching transactions: ${snapshot.error}');
            print('Stack trace: ${snapshot.stackTrace}');
            String errorMessage = snapshot.error.toString();
            if (errorMessage.contains('failed-precondition')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 40, color: Colors.red),
                    SizedBox(height: 10),
                    Text(
                      'Indeks diperlukan. Silakan buat indeks di Firebase Console dengan tautan ini:',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    SelectableText(
                      'https://console.firebase.google.com/v1/r/project/tokopediaclone-43eb0/firestore/indexes?create_composite=Cllwcm9qZWN0cy90b2tvcGVkaWFjbG9uZS00M2VIMC9kYXRhYmFzZXMvKGRIZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdHJhbnNhY3Rpb25zL2luZGV4ZXMvXxABGgoKBnVzZXJJZBABGgwKCXRpbWVzdGFtcBACGgwKCF9fbmFtZV9fEAI',
                      style: TextStyle(color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/transaction');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Utils.mainThemeColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            } else if (errorMessage.contains('permission-denied')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 40, color: Colors.red),
                    SizedBox(height: 10),
                    Text(
                      'Akses ditolak. Periksa aturan keamanan di Firebase Console.',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/transaction');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Utils.mainThemeColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 40, color: Colors.red),
                  SizedBox(height: 10),
                  Text(
                    'Terjadi kesalahan: ${errorMessage.split('\n').first}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/transaction');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Utils.mainThemeColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Coba Lagi', style: TextStyle(color: Colors.white)),
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
            print('No transactions found for userId: ${authService.currentUser!.uid}');
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
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  print('Processing transaction doc: ${doc.id}, data: $data');
                  return Transaction(
                    id: doc.id,
                    userId: data['userId'] as String? ?? '',
                    items: (data['items'] as List<dynamic>?)?.map((item) => item as Map<String, dynamic>).toList() ?? [],
                    totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
                    status: data['status'] as String? ?? 'Unknown',
                    timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  );
                } catch (e) {
                  print('Error mapping transaction ${doc.id}: $e');
                  return Transaction(
                    id: doc.id,
                    userId: authService.currentUser!.uid,
                    items: [],
                    totalPrice: 0.0,
                    status: 'Error',
                    timestamp: DateTime.now(),
                  );
                }
              })
              .toList();

          if (transactions.isEmpty) {
            print('Mapped transactions list is empty for userId: ${authService.currentUser!.uid}');
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

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: _getStatusIcon(transaction.status),
                  title: Text(
                    'Transaksi #${transaction.id.substring(0, 8)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                        'Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(transaction.timestamp)}',
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