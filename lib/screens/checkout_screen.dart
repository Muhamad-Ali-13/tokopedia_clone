import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/auth.dart';
import 'package:tokopedia_clone/providers/cart.dart';
import 'package:tokopedia_clone/models/transaction.dart';
import 'package:tokopedia_clone/utils/utils.dart'; // Pastikan Utils diimpor
import 'package:intl/intl.dart'; // Untuk format tanggal

class CheckoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (cart.items.isEmpty || authService.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'Keranjang kosong atau belum login',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.mainThemeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Kembali ke Beranda', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Utils.mainThemeColor, // Warna hijau Tokopedia
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = cart.items[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: cartItem.product.imageURL.isNotEmpty
                          ? Image.network(
                              cartItem.product.imageURL,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 40),
                            )
                          : Icon(Icons.image_not_supported, size: 40),
                    ),
                    title: Text(
                      cartItem.product.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'Rp ${cartItem.product.price.toStringAsFixed(0)} x ${cartItem.quantity}',
                          style: TextStyle(fontSize: 14, color: Utils.mainThemeColor),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Pesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    Text('Rp ${cart.totalPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ongkos Kirim', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    Text('Rp 10.000', style: TextStyle(fontSize: 14, color: Colors.black87)), // Placeholder
                  ],
                ),
                Divider(height: 24, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(
                      'Rp ${(cart.totalPrice + 10000).toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Utils.mainThemeColor),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final transaction = Transaction(
                        id: '',
                        userId: authService.currentUser!.uid,
                        items: cart.items.map((cartItem) => {
                          'id': cartItem.product.id,
                          'name': cartItem.product.name,
                          'price': cartItem.product.price,
                          'imageURL': cartItem.product.imageURL,
                          'quantity': cartItem.quantity,
                        }).toList(),
                        totalPrice: cart.totalPrice + 10000, // Tambahkan ongkos kirim
                        status: 'pending',
                        timestamp: DateTime.now(),
                      );
                      await FirebaseFirestore.instance.collection('transactions').add({
                        'userId': transaction.userId,
                        'items': transaction.items,
                        'totalPrice': transaction.totalPrice,
                        'status': transaction.status,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      cart.clear();
                      Navigator.popUntil(context, (route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pesanan berhasil dikonfirmasi')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal memproses pesanan: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Utils.mainThemeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size(double.infinity, 50),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Konfirmasi Pesanan',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}