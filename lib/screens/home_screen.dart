import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/models/product.dart';
import 'package:tokopedia_clone/providers/cart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedTag;

  @override
  Widget build(BuildContext context) {
    final categories = [
      'MURAH Meriah',
      'BELI LOKAL',
      'KEWAN',
      'PROMO HARI INI',
      'FASHION',
      'TOKOPE FARMA',
      'TOSERBA',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari di Tokopedia',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selectedTag == category,
                    onSelected: (selected) {
                      setState(() {
                        selectedTag = selected ? category : null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data;
                if (data == null || data.docs.isEmpty) {
                  return Center(child: Text('Tidak ada produk tersedia'));
                }

                var products = data.docs.map((doc) {
                  try {
                    return Product(
                      id: doc.id,
                      name: doc['name'] as String? ?? 'Nama tidak tersedia',
                      price: (doc['price'] as num?)?.toDouble() ?? 0.0,
                      imageURL: (doc['imageURL'] as String?) ?? '',
                      rating: (doc['rating'] as num?)?.toDouble() ?? 0.0,
                      soldCount: (doc['soldCount'] as int?) ?? 0,
                      location: (doc['location'] as String?) ?? '',
                      tags: List<String>.from(doc['tags'] ?? []),
                      discount: (doc['discount'] as num?)?.toDouble(),
                    );
                  } catch (e) {
                    print('Error mapping product: $e');
                    return Product(
                      id: doc.id,
                      name: 'Produk Error',
                      price: 0.0,
                      imageURL: '',
                      rating: 0.0,
                      soldCount: 0,
                      location: '',
                      tags: [],
                      discount: null,
                    );
                  }
                }).toList();

                if (selectedTag != null) {
                  products = products.where((product) => product.tags.contains(selectedTag)).toList();
                }

                return Consumer<Cart>(
                  builder: (context, cart, child) {
                    return GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          elevation: 2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/product_detail', arguments: product);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: product.imageURL.isNotEmpty
                                      ? Image.network(
                                          product.imageURL,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.image_not_supported, size: 50);
                                          },
                                        )
                                      : Icon(Icons.image_not_supported, size: 50),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    product.name,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'Rp ${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 14, color: Colors.green),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.yellow, size: 16),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${product.rating} • ${product.soldCount}+ terjual${product.discount != null ? ', disk ${product.discount}%' : ''} • ${product.location}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (product.tags.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Chip(
                                      label: Text(product.tags.first),
                                      backgroundColor: Colors.green.withOpacity(0.2),
                                      labelStyle: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.add_shopping_cart, color: Colors.green),
                                    onPressed: () {
                                      cart.addItem(product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}