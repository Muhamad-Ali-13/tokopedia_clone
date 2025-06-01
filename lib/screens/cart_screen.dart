import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/cart.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
      ),
      body: cart.items.isEmpty
          ? Center(child: Text('Keranjang kosong'))
          : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final product = cart.items[index];
                return ListTile(
                  leading: product.imageURL.isNotEmpty
                      ? Image.network(product.imageURL, width: 50, fit: BoxFit.cover)
                      : Icon(Icons.image_not_supported),
                  title: Text(product.name),
                  subtitle: Text('Rp ${product.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      cart.removeItem(product.id);
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isNotEmpty
          ? Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total: Rp ${cart.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/checkout'),
                    child: Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}