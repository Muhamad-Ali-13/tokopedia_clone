import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/models/transaction.dart';
import 'package:tokopedia_clone/providers/auth.dart';

class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    if (authService.currentUser == null) {
      return Center(child: Text('Silakan login terlebih dahulu'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Transaksi'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: authService.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null || data.docs.isEmpty) {
            return Center(child: Text('Tidak ada riwayat transaksi'));
          }

          final transactions = data.docs.map((doc) => Transaction.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                title: Text('Transaksi #${transaction.id}'),
                subtitle: Text('Total: Rp ${transaction.totalPrice.toStringAsFixed(2)} - Status: ${transaction.status}'),
                trailing: Text(transaction.timestamp.toString()),
              );
            },
          );
        },
      ),
    );
  }
}