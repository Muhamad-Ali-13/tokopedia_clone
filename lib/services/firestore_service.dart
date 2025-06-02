import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokopedia_clone/models/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSampleProducts() async {
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Kaos Polos Putih',
        'price': 50000,
        'imageURL': 'https://example.com/kaos_putih.jpg',
        'rating': 4.5,
        'soldCount': 150,
        'location': 'Jakarta',
        'tags': ['FASHION', 'MURAH Meriah'],
        'discount': 10,
      },
      {
        'name': 'Makanan Kucing Whiskas 1kg',
        'price': 75000,
        'imageURL': 'https://example.com/makanan_kucing.jpg',
        'rating': 4.2,
        'soldCount': 200,
        'location': 'Surabaya',
        'tags': ['KEWAN', 'BELI LOKAL'],
        'discount': null,
      },
      {
        'name': 'Sepatu Sneaker Lokal Ventela',
        'price': 250000,
        'imageURL': 'https://example.com/sepatu_ventela.jpg',
        'rating': 4.7,
        'soldCount': 80,
        'location': 'Bandung',
        'tags': ['FASHION', 'BELI LOKAL'],
        'discount': 15,
      },
      {
        'name': 'Paracetamol 500mg (10 Tablet)',
        'price': 15000,
        'imageURL': 'https://example.com/paracetamol.jpg',
        'rating': 4.8,
        'soldCount': 300,
        'location': 'Yogyakarta',
        'tags': ['TOKOPE FARMA', 'PROMO HARI INI'],
        'discount': 5,
      },
      {
        'name': 'Tas Selempang Wanita Kulit Sintetis',
        'price': 120000,
        'imageURL': 'https://example.com/tas_selempang.jpg',
        'rating': 4.3,
        'soldCount': 90,
        'location': 'Medan',
        'tags': ['FASHION', 'MURAH Meriah'],
        'discount': null,
      },
      {
        'name': 'Mainan Edukatif Puzzle Kayu',
        'price': 45000,
        'imageURL': 'https://example.com/puzzle_kayu.jpg',
        'rating': 4.6,
        'soldCount': 120,
        'location': 'Semarang',
        'tags': ['TOSERBA', 'BELI LOKAL'],
        'discount': 20,
      },
      {
        'name': 'Shampoo Anti Ketombe 300ml',
        'price': 35000,
        'imageURL': 'https://example.com/shampoo.jpg',
        'rating': 4.4,
        'soldCount': 250,
        'location': 'Bali',
        'tags': ['TOSERBA', 'PROMO HARI INI'],
        'discount': 10,
      },
      {
        'name': 'Jaket Hoodie Pria Polos',
        'price': 180000,
        'imageURL': 'https://example.com/hoodie.jpg',
        'rating': 4.5,
        'soldCount': 70,
        'location': 'Makassar',
        'tags': ['FASHION', 'MURAH Meriah'],
        'discount': null,
      },
      {
        'name': 'Vitamin C 1000mg (30 Tablet)',
        'price': 60000,
        'imageURL': 'https://example.com/vitamin_c.jpg',
        'rating': 4.9,
        'soldCount': 400,
        'location': 'Palembang',
        'tags': ['TOKOPE FARMA', 'PROMO HARI INI'],
        'discount': 15,
      },
      {
        'name': 'Kandang Kelinci Minimalis',
        'price': 95000,
        'imageURL': 'https://example.com/kandang_kelinci.jpg',
        'rating': 4.1,
        'soldCount': 50,
        'location': 'Malang',
        'tags': ['KEWAN', 'BELI LOKAL'],
        'discount': null,
      },
    ];

    for (var product in products) {
      await _firestore.collection('products').add(product);
    }
  }
}