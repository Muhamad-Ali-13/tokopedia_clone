import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/models/product.dart';
import 'package:tokopedia_clone/providers/cart.dart';

class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final cart = Provider.of<Cart>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product.imageURL.isNotEmpty
                ? Image.network(
                    product.imageURL,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported, size: 100);
                    },
                  )
                : Icon(Icons.image_not_supported, size: 100),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rp ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                  if (product.discount != null)
                    Text(
                      'Diskon ${product.discount}%',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${product.rating} • ${product.soldCount}+ terjual • ${product.location}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: product.tags.map((tag) => Chip(label: Text(tag))).toList(),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            cart.addItem(product);
                            Navigator.pushNamed(context, '/cart');
                          },
                          child: Text('Tambah ke Keranjang'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            cart.addItem(product);
                            Navigator.pushNamed(context, '/checkout');
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: Text('Beli Sekarang'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}