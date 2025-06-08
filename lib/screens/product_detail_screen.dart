import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/models/product.dart';
import 'package:tokopedia_clone/providers/cart.dart';
import 'package:tokopedia_clone/providers/wishlist.dart';
import 'package:tokopedia_clone/utils/utils.dart';

class ProductDetailScreen extends StatefulWidget {
  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final wishlist = Provider.of<Wishlist>(context);
    final productMap = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final product = productMap != null && productMap['id'] != null
        ? Product.fromJson(productMap, productMap['id'] as String)
        : null;

    if (product == null || product.id == null) {
      return Scaffold(
        body: Center(
          child: Text('Error: Product data not provided or invalid'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          SizedBox(width: 8),
        ],
        backgroundColor: Utils.mainThemeColor,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive image container
            AspectRatio(
              aspectRatio: 1.0,
              child: product.imageURL != null && product.imageURL!.isNotEmpty
                  ? Image.network(
                      product.imageURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                        );
                      },
                    )
                  : Center(
                      child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name ?? 'Unnamed Product',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Wishlist button with live update
                      IconButton(
                        icon: Icon(
                          wishlist.items.any((item) => item.id == product.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: wishlist.items.any((item) => item.id == product.id)
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            if (wishlist.items.any((item) => item.id == product.id)) {
                              wishlist.removeItem(product.id!);
                            } else {
                              wishlist.addItem(product);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Rp ${product.price?.toStringAsFixed(0) ?? '0'}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.discount != null) ...[
                        SizedBox(width: 8),
                        Text(
                          'Rp ${(product.price! * (1 - (product.discount! / 100))).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${product.discount!.toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${product.rating?.toStringAsFixed(1) ?? '0.0'} (${product.soldCount ?? 0}) • Foto ulasan • Terjual',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ongkir mulai Rp11.700 - Est. tiba 20 - 26 Jun',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    cart.addItem(product);
                    Navigator.pushNamed(context, '/checkout');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Beli Langsung', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => cart.addItem(product),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('+ Keranjang', style: TextStyle(color: Colors.green)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
