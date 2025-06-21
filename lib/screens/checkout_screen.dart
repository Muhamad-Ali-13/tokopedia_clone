import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/cart.dart';
import 'package:tokopedia_clone/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokopedia_clone/providers/auth.dart';
import 'package:tokopedia_clone/providers/wishlist.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedShipping = 'Standard (Rp0)';
  String _selectedPayment = 'COD (Bayar di Tempat)';
  bool _useInsurance = false;
  bool _useProtection = true;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final wishlist = Provider.of<Wishlist>(context, listen: false);
    final items = cart.items;

    double totalPrice = items.fold(0, (sum, item) {
      double basePrice = item.product.price ?? 0.0;
      double discount = (item.product.discount ?? 0.0).toDouble();
      double itemTotal = basePrice * item.quantity;
      return sum +
          (discount > 0
              ? (itemTotal * (1 - discount / 100)).roundToDouble()
              : itemTotal);
    });
    double insuranceFee = _useInsurance ? 400 : 0;
    double protectionFee = _useProtection ? items.length * 1250 : 0;
    double shippingFee =
        _selectedShipping.contains('Rp')
            ? double.parse(
              _selectedShipping
                  .split('Rp')[1]
                  .replaceAll(')', '')
                  .replaceAll('(', ''),
            )
            : 0;
    double codFee =
        _selectedPayment.contains('COD')
            ? (totalPrice * 0.01).roundToDouble()
            : 0;
    double total =
        totalPrice + shippingFee + insuranceFee + protectionFee + codFee;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Utils.mainThemeColor,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.location_on, color: Utils.mainThemeColor),
              title: Text(
                'Rumah · Muhammad Ali',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Jl. Kirapandak, Kp. Kirapandak 004/001 Dekat Mesjid',
              ),
              trailing: Icon(Icons.chevron_right, color: Utils.mainThemeColor),
              onTap: () {},
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Pesanan Kamu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...items.map((item) => _buildItemTile(item)).toList(),
          SizedBox(height: 16),
          Text(
            'Pilih Ongkir',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildShippingOption('Standard (Rp0) - Est. tiba 6-12 Jun'),
          SizedBox(height: 16),
          CheckboxListTile(
            value: _useInsurance,
            onChanged: (v) => setState(() => _useInsurance = v!),
            title: Text(
              'Pakai Asuransi Pengiriman (Rp400)',
              style: TextStyle(fontSize: 16),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Utils.mainThemeColor,
          ),
          SizedBox(height: 16),
          CheckboxListTile(
            value: _useProtection,
            onChanged: (v) => setState(() => _useProtection = v!),
            title: Text(
              'Proteksi Rusak Uang Kembali 100% (Rp1250/item)',
              style: TextStyle(fontSize: 16),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Utils.mainThemeColor,
          ),
          SizedBox(height: 16),
          Text(
            'Metode Pembayaran',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildPaymentOption('BCA Virtual Account'),
          _buildPaymentOption('Mandiri Virtual Account'),
          _buildPaymentOption('BRI Virtual Account'),
          _buildPaymentOption('COD (Bayar di Tempat)'),
          SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cek ringkasan belanjaanmu, yuk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildSummaryRow(
                    'Total Harga (${items.length} Barang)',
                    totalPrice,
                  ),
                  _buildSummaryRow('Total Ongkos Kirim', shippingFee),
                  _buildSummaryRow('Total Asuransi Pengiriman', insuranceFee),
                  _buildSummaryRow('Total Biaya Proteksi', protectionFee),
                  _buildSummaryRow('Biaya Bayar di Tempat', codFee),
                  Divider(thickness: 2),
                  _buildSummaryRow('Total Tagihan', total, isBold: true),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (authService.currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Silakan login terlebih dahulu!')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance.collection('transactions').add(
                  {
                    'userId': authService.currentUser!.uid,
                    'items':
                        items.map((item) {
                          double basePrice = item.product.price ?? 0.0;
                          double discount =
                              (item.product.discount ?? 0.0).toDouble();
                          double discountedPrice =
                              discount > 0
                                  ? (basePrice * (1 - discount / 100))
                                      .roundToDouble()
                                  : basePrice;
                          return {
                            'productId': item.product.id,
                            'name': item.product.name,
                            'price': basePrice,
                            'discountedPrice': discountedPrice,
                            'quantity': item.quantity,
                            'discount': discount,
                            'imageURL': item.product.imageURL ?? '',
                          };
                        }).toList(),
                    'totalPrice': total,
                    'status': 'dibayar',
                    'timestamp': FieldValue.serverTimestamp(),
                    'shippingFee': shippingFee,
                    'insuranceFee': insuranceFee,
                    'protectionFee': protectionFee,
                    'codFee': codFee,
                  },
                );

                int removedCount = 0;
                for (var item in items) {
                  if (wishlist.items.any(
                    (wishlistItem) => wishlistItem.id == item.product.id,
                  )) {
                    wishlist.removeItem(item.product.id!);
                    removedCount++;
                  }
                }

                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Pembayaran Berhasil'),
                        content: Text(
                          'Transaksi Anda telah diproses. Lihat riwayat transaksi untuk detail.\n'
                          '${removedCount > 0 ? '$removedCount produk dihapus dari wishlist.' : ''}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // tutup dialog
                              cart.clear(); // kosongkan keranjang

                              // Navigasi ke halaman transaksi
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/transaction',
                                (route) => false,
                              );
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saat memproses transaksi: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Utils.mainThemeColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Bayar Sekarang',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(CartItem item) {
    double basePrice = item.product.price ?? 0.0;
    double discount = (item.product.discount ?? 0.0).toDouble();
    double discountedPrice =
        discount > 0
            ? (basePrice * (1 - discount / 100)).roundToDouble()
            : basePrice;
    double itemTotal = discountedPrice * item.quantity;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  item.product.imageURL != null &&
                          item.product.imageURL!.isNotEmpty
                      ? Image.network(
                        item.product.imageURL!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Icon(Icons.image_not_supported, size: 40),
                      )
                      : Icon(Icons.image_not_supported, size: 40),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name ?? 'Unnamed Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp${itemTotal.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 14, color: Utils.mainThemeColor),
                  ),
                  if (discount > 0)
                    Text(
                      '${discount.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingOption(String label) {
    return RadioListTile<String>(
      value: label,
      groupValue: _selectedShipping,
      onChanged: (v) => setState(() => _selectedShipping = v!),
      title: Text(label, style: TextStyle(fontSize: 16)),
      activeColor: Utils.mainThemeColor,
    );
  }

  Widget _buildPaymentOption(String label) {
    return RadioListTile<String>(
      value: label,
      groupValue: _selectedPayment,
      onChanged: (v) => setState(() => _selectedPayment = v!),
      title: Text(label, style: TextStyle(fontSize: 16)),
      activeColor: Utils.mainThemeColor,
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            'Rp${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
              color: isBold ? Utils.mainThemeColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
