import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/models/product.dart';
import 'package:tokopedia_clone/providers/cart.dart';
import 'package:tokopedia_clone/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedTag;

  final List<String> categories = [
    'MURAH MERIAH',
    'BELI LOKAL',
    'HEWAN',
    'PROMO HARI INI',
    'FASHION',
    'TOKOPEDIA FARMA',
    'TOSERBA',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/tokopedia.png', // Ganti dengan logo Tokopedia dari assets
            height: 30,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.store, color: Colors.white),
          ),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
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
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
        backgroundColor: Utils.mainThemeColor,
        elevation: 2,
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selectedTag == category ? Utils.mainThemeColor : Colors.black87,
                      ),
                    ),
                    selected: selectedTag == category,
                    onSelected: (selected) {
                      setState(() {
                        selectedTag = selected ? category : null;
                      });
                    },
                    selectedColor: Utils.mainThemeColor.withOpacity(0.2),
                    backgroundColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        SizedBox(height: 10),
                        Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Utils.mainThemeColor,
                    ),
                  );
                }
                final data = snapshot.data;
                if (data == null || data.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 40),
                        SizedBox(height: 10),
                        Text(
                          'Tidak ada produk tersedia',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
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
                      name: 'Nama tidak tersedia',
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
                      padding: EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75, // Disesuaikan untuk layout yang lebih proporsional
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/product_detail', arguments: product);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                  child: product.imageURL.isNotEmpty
                                      ? Image.network(
                                          product.imageURL,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 120,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 120,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          height: 120,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'Rp ${product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Utils.mainThemeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.yellow[700], size: 16),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${product.rating} • ${product.soldCount}+ terjual${product.discount != null ? ' • Diskon ${product.discount}%' : ''}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    product.location,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ),
                                if (product.tags.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                    child: Chip(
                                      label: Text(
                                        product.tags.first,
                                        style: TextStyle(fontSize: 10, color: Utils.mainThemeColor),
                                      ),
                                      backgroundColor: Utils.mainThemeColor.withOpacity(0.1),
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add_shopping_cart,
                                      color: Utils.mainThemeColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      cart.addItem(product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${product.name} ditambahkan ke keranjang'),
                                          backgroundColor: Utils.mainThemeColor,
                                        ),
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