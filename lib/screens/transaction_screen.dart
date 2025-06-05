import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/models/transaction.dart';
import 'package:tokopedia_clone/providers/auth.dart';
import 'package:tokopedia_clone/utils/utils.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statusTabs = ['Semua', 'Dibayar', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 50, color: Colors.grey),
              const SizedBox(height: 10),
              const Text(
                'Silakan login terlebih dahulu',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.mainThemeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Utils.mainThemeColor,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _statusTabs.map((status) => Tab(text: status)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statusTabs.map((tabStatus) {
          return StreamBuilder<QuerySnapshot>(
            stream: _buildStream(authService.currentUser!.uid, tabStatus),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Error fetching transactions: ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 40, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(
                        'Terjadi kesalahan: ${snapshot.error.toString().split('\n').first}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => (context as Element).markNeedsBuild(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Utils.mainThemeColor));
              }
              final data = snapshot.data;
              if (data == null || data.docs.isEmpty) {
                return const Center(
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

              final transactions = data.docs.map((doc) {
                try {
                  return Transaction.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
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
              }).toList();

              // Group transactions by date
              final groupedTransactions = _groupTransactionsByDate(transactions);

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: groupedTransactions.length,
                itemBuilder: (context, index) {
                  final dateGroup = groupedTransactions.keys.toList()[index];
                  final groupItems = groupedTransactions[dateGroup]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Text(
                          dateGroup,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),
                      ...groupItems.map((transaction) {
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.store, size: 20, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Toko ${transaction.id.substring(0, 8)}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Chip(
                                      label: Text(
                                        transaction.status,
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                      backgroundColor: _getStatusColor(transaction.status),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(transaction.timestamp)}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Total: Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 14, color: Utils.mainThemeColor, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/transaction_detail',
                                          arguments: {'transaction': transaction},
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(color: Utils.mainThemeColor),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      ),
                                      child: const Text(
                                        'Lihat Detail',
                                        style: TextStyle(fontSize: 12, color: Utils.mainThemeColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Stream<QuerySnapshot> _buildStream(String userId, String tabStatus) {
    var query = FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    if (tabStatus != 'Semua') {
      query = query.where('status', isEqualTo: tabStatus);
    }

    return query.snapshots();
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var transaction in transactions) {
      final date = DateTime(
        transaction.timestamp.year,
        transaction.timestamp.month,
        transaction.timestamp.day,
      );
      String groupKey;

      if (date == today) {
        groupKey = 'Hari Ini';
      } else if (date == yesterday) {
        groupKey = 'Kemarin';
      } else {
        groupKey = DateFormat('dd MMM yyyy').format(date);
      }

      grouped.putIfAbsent(groupKey, () => []).add(transaction);
    }

    return grouped;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dibayar':
        return Colors.blue;
      case 'diproses':
        return Colors.orange;
      case 'dikirim':
        return Colors.purple;
      case 'selesai':
        return Utils.mainThemeColor;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}