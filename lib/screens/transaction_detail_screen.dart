import 'package:flutter/material.dart';
import 'package:tokopedia_clone/models/transaction.dart';
import 'package:tokopedia_clone/utils/utils.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  TransactionDetailScreen({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Transaksi #${transaction.id}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Utils.mainThemeColor,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaksi #${transaction.id}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Chip(
                          label: Text(
                            transaction.status,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: _getStatusColor(transaction.status),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(transaction.timestamp)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: transaction.items.length,
                      itemBuilder: (context, index) {
                        final item = transaction.items[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.local_mall, size: 20, color: Colors.grey),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? 'Produk tidak diketahui',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Jumlah: ${item['quantity']} • Rp ${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Harga',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        Text(
                          'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Utils.mainThemeColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Tombol aksi berdasarkan status
            if (transaction.status == 'Dikirim')
              ElevatedButton(
                onPressed: () {
                  // Logika konfirmasi terima barang (opsional, tambahkan fungsi di sini)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Barang dikonfirmasi diterima!'),
                      backgroundColor: Utils.mainThemeColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.mainThemeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Konfirmasi Terima Barang',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            if (transaction.status == 'Diproses' || transaction.status == 'Dikirim')
              ElevatedButton(
                onPressed: () {
                  // Logika hubungi penjual (opsional, tambahkan fungsi di sini)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hubungi penjual melalui chat...'),
                      backgroundColor: Utils.mainThemeColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.mainThemeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Hubungi Penjual',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menentukan warna berdasarkan status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'dikirim':
      case 'diproses':
        return Colors.orange;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}