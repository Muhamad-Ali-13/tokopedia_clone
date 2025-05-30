import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/cart.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Belanja'),
      ),
      body: cart.items.isEmpty
          ? Center(child: Text('Keranjang Anda kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items.values.toList()[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ListTile(
                          leading: cartItem.product.imageURL!.isNotEmpty
                              ? Image.network(
                                  cartItem.product.imageURL!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported);
                                  },
                                )
                              : Icon(Icons.image_not_supported),
                          title: Text(cartItem.product.name),
                          subtitle: Text('Rp ${cartItem.product.price.toStringAsFixed(2)} x ${cartItem.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Rp ${cartItem.toStringAsFixed(2)}'),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cart.removeItem(cartItem.product.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${cartItem.product.name} dihapus dari keranjang')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: Rp ${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          if (cart.items.isNotEmpty) {
                            await FirebaseFirestore.instance.collection('transactions').add({
                              'userId': '1gLiGxCGhosRq8P11eO2', // Ganti dengan userId dari LoginService nanti
                              'items': cart.items.values
                                  .map((item) => {
                                        'productId': item.product.id,
                                        'name': item.product.name,
                                        'price': item.product.price,
                                        'quantity': item.quantity,
                                      })
                                  .toList(),
                              'totalAmount': cart.totalAmount,
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                            cart.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Transaksi berhasil!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Keranjang kosong, tambah item terlebih dahulu!')),
                            );
                          }
                        },
                        child: Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}