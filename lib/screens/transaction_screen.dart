import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tokopedia_clone/models/transaction.dart';
import 'package:tokopedia_clone/providers/auth.dart';
import 'package:tokopedia_clone/utils/utils.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  Transaction? selectedTransaction;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.currentUser == null) {
      return Scaffold(
        body: Center(child: Text("Silakan login terlebih dahulu.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          selectedTransaction == null ? 'Transaksi' : 'Detail Pesanan',
          style: TextStyle(color: Colors.black),
        ),
        leading: selectedTransaction != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => setState(() => selectedTransaction = null),
              )
            : null,
        elevation: 1,
      ),
      body: selectedTransaction == null
          ? _buildTransactionList(authService.currentUser!.uid)
          : _buildTransactionDetail(selectedTransaction!),
    );
  }

  Widget _buildTransactionList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Gagal memuat data"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!.docs.map((doc) {
          return Transaction.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        if (transactions.isEmpty) {
          return Center(child: Text("Belum ada transaksi"));
        }

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final t = transactions[index];

            final firstItem = (t.items?.isNotEmpty ?? false) ? t.items!.first : {};
            final imageURL = firstItem['imageURL'] ?? '';
            final productName = firstItem['name'] ?? 'Produk tidak diketahui';

            return GestureDetector(
              onTap: () => setState(() => selectedTransaction = t),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: imageURL != ''
                      ? Image.network(imageURL, width: 50, height: 50, fit: BoxFit.cover)
                      : Container(width: 50, height: 50, color: Colors.grey[300]),
                  title: Text(productName, maxLines: 1),
                  subtitle: Text('Total Belanja: Rp${t.totalPrice.toStringAsFixed(0)}'),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(t.status ?? '', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionDetail(Transaction t) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    final firstItem = (t.items?.isNotEmpty ?? false) ? t.items!.first : {};
    final imageURL = firstItem['imageURL'] ?? '';
    final productName = firstItem['name'] ?? 'Produk tidak diketahui';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section(
          title: 'No. Pesanan: ${t.id}',
          trailing: TextButton(
            onPressed: () {},
            child: Text('Lihat Invoice', style: TextStyle(color: Colors.green)),
          ),
          children: [
            _infoRow('Tanggal Pembelian', DateFormat('dd MMM yyyy, HH:mm').format(t.timestamp) + ' WIB'),
            _infoRow('Selesai Otomatis', DateFormat('dd MMM, HH:mm').format(t.timestamp.add(Duration(days: 6))) + ' WIB', highlight: true),
          ],
        ),
        SizedBox(height: 16),
        _section(
          title: 'Detail Produk',
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageURL != ''
                      ? Image.network(
                          imageURL,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[300]),
                        )
                      : Container(width: 50, height: 50, color: Colors.grey[300]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dilindungi Proteksi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('1 x ${currency.format(t.totalPrice)}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        _section(
          leadingIcon: Icons.verified_user,
          title: 'Kamu pakai proteksi di transaksi ini',
          subtitle: 'Setelah pesanan selesai, kamu bisa cek polis dan ajukan',
          trailingIcon: Icons.arrow_forward_ios,
          color: Colors.blue[50],
        ),
        SizedBox(height: 16),
        _section(
          title: 'Info Pengiriman',
          trailing: TextButton(
            onPressed: () {},
            child: Text('Lihat Detail', style: TextStyle(color: Colors.green)),
          ),
          children: [
            _infoRow('Kurir', 'Standard GRATIS ONGKIR', highlight: true),
            _infoRow('No Resi', t.trackingNumber ?? 'TKP5030291880'),
            _infoRow('Alamat', t.address ?? 'Alamat tidak tersedia', multiline: true),
          ],
        ),
        SizedBox(height: 16),
        _section(
          title: 'Rincian Pembayaran',
          children: [
            _infoRow('Metode Pembayaran', t.paymentOption ?? 'COD (Bayar di Tempat)'),
            SizedBox(height: 8),
            _priceRow('Subtotal Harga Barang', t.subtotal ?? 0),
            _priceRow('Total Ongkos Kirim', t.shippingCost ?? 0),
            _priceRow('Proteksi Produk', t.protectionFee ?? 0),
            _priceRow('Asuransi Pengiriman', t.insuranceFee ?? 0),
            _priceRow('Biaya COD', t.codFee ?? 0),
            Divider(),
            _priceRow('Total Belanja', t.totalPrice, bold: true),
            SizedBox(height: 4),
            Text('Belum termasuk biaya transaksi. Cek detailnya di invoice, ya.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ]),
    );
  }

  Widget _section({
    required String title,
    List<Widget>? children,
    Widget? trailing,
    IconData? leadingIcon,
    String? subtitle,
    IconData? trailingIcon,
    Color? color,
  }) {
    return Card(
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              if (leadingIcon != null) Icon(leadingIcon, color: Colors.blue),
              if (leadingIcon != null) SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    if (subtitle != null)
                      Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ],
                ),
              ),
              if (trailingIcon != null) Icon(trailingIcon, size: 16),
              if (trailing != null) trailing,
            ],
          ),
          if (children != null) ...[SizedBox(height: 12), ...children],
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false, bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(width: 120, child: Text(label, style: TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: TextStyle(color: highlight ? Colors.green : Colors.black))),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool bold = false}) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(format.format(amount), style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
