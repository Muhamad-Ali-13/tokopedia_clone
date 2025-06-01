import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/auth.dart';
import 'package:tokopedia_clone/providers/cart.dart';
import 'package:tokopedia_clone/models/transaction.dart';

class CheckoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: cart.items.isEmpty
          ? Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final product = cart.items[index];
                      return ListTile(
                        leading: product.imageURL.isNotEmpty
                            ? Image.network(product.imageURL, width: 50, fit: BoxFit.cover)
                            : Icon(Icons.image_not_supported),
                        title: Text(product.name),
                        subtitle: Text('Rp ${product.price.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total: Rp ${cart.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final transaction = Transaction(
                            id: '',
                            userId: authService.currentUser!.uid,
                            products: cart.items,
                            totalPrice: cart.totalPrice,
                            status: 'pending',
                            timestamp: DateTime.now(),
                          );
                          await FirebaseFirestore.instance.collection('transactions').add({
                            'userId': transaction.userId,
                            'products': transaction.products.map((product) => {
                              'id': product.id,
                              'name': product.name,
                              'price': product.price,
                              'imageURL': product.imageURL,
                            }).toList(),
                            'totalPrice': transaction.totalPrice,
                            'status': transaction.status,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          cart.clear();
                          Navigator.popUntil(context, (route) => route.isFirst);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Pesanan berhasil dikonfirmasi')),
                          );
                        },
                        child: Text('Konfirmasi Pesanan'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
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