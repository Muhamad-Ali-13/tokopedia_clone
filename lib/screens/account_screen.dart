import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/auth.dart';
import 'package:tokopedia_clone/utils/utils.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100], // Latar belakang abu-abu muda seperti Tokopedia
      appBar: AppBar(
        title: Text(
          'Akun Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Utils.mainThemeColor, // Hijau Tokopedia
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back otomatis
      ),
      body: authService.currentUser == null
          ? _buildNotLoggedIn(context)
          : _buildLoggedIn(context, authService),
    );
  }

  // UI untuk pengguna yang belum login
  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Silakan login untuk melihat akun Anda',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Utils.mainThemeColor,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Login Sekarang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI untuk pengguna yang sudah login
  Widget _buildLoggedIn(BuildContext context, AuthService authService) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan foto profil dan informasi pengguna
          Container(
            color: Utils.mainThemeColor,
            padding: EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Utils.mainThemeColor.withOpacity(0.2),
                    child: authService.currentUser?.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              authService.currentUser!.photoURL!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.person,
                                size: 40,
                                color: Utils.mainThemeColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 40,
                            color: Utils.mainThemeColor,
                          ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authService.currentUser!.email!.split('@')[0], // Nama placeholder dari email
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          authService.currentUser!.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Utils.mainThemeColor, size: 20),
                    onPressed: () {
                      // Navigasi ke layar edit profil (opsional)
                      // Navigator.pushNamed(context, '/edit_profile');
                    },
                  ),
                ],
              ),
            ),
          ),
          // Menu Akun
          Container(
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline, color: Utils.mainThemeColor),
                  title: Text(
                    'Profil Saya',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Navigasi ke layar profil (opsional)
                    // Navigator.pushNamed(context, '/profile');
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
                ListTile(
                  leading: Icon(Icons.shopping_bag_outlined, color: Utils.mainThemeColor),
                  title: Text(
                    'Pesanan Saya',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.pushNamed(context, '/transaction');
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
                ListTile(
                  leading: Icon(Icons.location_on_outlined, color: Utils.mainThemeColor),
                  title: Text(
                    'Alamat Pengiriman',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Navigasi ke layar alamat (opsional)
                    // Navigator.pushNamed(context, '/shipping_address');
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
                ListTile(
                  leading: Icon(Icons.payment_outlined, color: Utils.mainThemeColor),
                  title: Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Navigasi ke layar metode pembayaran (opsional)
                    // Navigator.pushNamed(context, '/payment_methods');
                  },
                ),
              ],
            ),
          ),
          // Pengaturan Lain
          Container(
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outline, color: Utils.mainThemeColor),
                  title: Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Navigasi ke layar ubah kata sandi (opsional)
                    // Navigator.pushNamed(context, '/change_password');
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Utils.mainThemeColor),
                  title: Text(
                    'Pusat Bantuan',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Navigasi ke layar bantuan (opsional)
                    // Navigator.pushNamed(context, '/help_center');
                  },
                ),
              ],
            ),
          ),
          // Tombol Logout
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ElevatedButton(
              onPressed: () async {
                await authService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red, width: 1),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 0),
              ),
              child: Text(
                'Keluar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}