import 'package:flutter/material.dart';
import 'package:tokopedia_clone/utils/utils.dart'; // Pastikan Utils diimpor

class PromoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Promo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Utils.mainThemeColor, // Warna hijau Tokopedia
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back otomatis
      ),
      body: Container(
        color: Colors.grey[100], // Latar belakang abu-abu muda seperti Tokopedia
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_offer, // Ikon promo placeholder
                size: 80,
                color: Utils.mainThemeColor.withOpacity(0.7),
              ),
              SizedBox(height: 20),
              Text(
                'Fitur Promo - Coming Soon!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Kami sedang menyiapkan promo menarik untuk Anda. Tunggu sebentar lagi ya!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.mainThemeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}