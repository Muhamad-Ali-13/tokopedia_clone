import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/auth.dart';
import 'package:tokopedia_clone/utils/utils.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        print('Building AccountScreen, currentUser: ${authService.currentUser?.uid ?? "null"}');
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text(
              'Akun Saya',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            backgroundColor: Utils.mainThemeColor,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: authService.currentUser == null
              ? _buildNotLoggedIn(context)
              : _buildLoggedIn(context, authService),
        );
      },
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    print('Rendering not logged in view');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Silakan login untuk melihat akun Anda',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Utils.mainThemeColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
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

  Widget _buildLoggedIn(BuildContext context, AuthService authService) {
    print('Rendering logged in view for user: ${authService.currentUser?.uid}');
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            color: Utils.mainThemeColor,
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person,
                                size: 40,
                                color: Utils.mainThemeColor,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 40,
                            color: Utils.mainThemeColor,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authService.currentUser?.displayName ??
                              authService.currentUser!.email!.split('@')[0],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authService.currentUser!.email ?? 'email@example.com',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.black87,
                      size: 24,
                    ),
                    onPressed: () {
                      // Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),
          ),
          // Promo Notification
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.yellow, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Klaim diskon s.d. 40% untuk belanja',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'Yuk segera pakai, khusus belanja pertamamu!',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onPressed: () {
                    // Navigator.pushNamed(context, '/promo');
                  },
                ),
              ],
            ),
          ),
          // Quick Actions
          Container(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Transaksi Saya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(context, Icons.account_balance_wallet, 'Bayar', '/transactions?status=bayar'),
                    _buildQuickAction(context, Icons.hourglass_empty, 'Diproses', '/transactions?status=diproses'),
                    _buildQuickAction(context, Icons.local_shipping, 'Dikirim', '/transactions?status=dikirim'),
                    _buildQuickAction(context, Icons.check_circle_outline, 'Selesai', '/transactions?status=selesai'),
                  ],
                ),
              ],
            ),
          ),
          // Saldo & Points
          Container(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Saldo & Points',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(Icons.account_balance, 'Saldo Tokopedia', 'Rp 0', onTap: () {}),
                _buildMenuItem(Icons.card_giftcard, 'Bonus', '0', color: Colors.orange, onTap: () {}),
              ],
            ),
          ),
          // Menu Lainnya
          Container(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(
                    'Menu Lainnya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildMenuItem(Icons.store, 'Buka Toko', '', onTap: () {}),
                _buildMenuItem(Icons.local_offer, 'Kupon Saya', '', onTap: () {}),
                _buildMenuItem(Icons.favorite_border, 'Wishlist', '', onTap: () {
                  Navigator.pushNamed(context, '/wishlist');
                }),
                _buildMenuItem(Icons.star_border, 'Ulasan Saya', '', onTap: () {}),
                _buildMenuItem(Icons.support_agent, 'Pusat Bantuan', '', onTap: () {}),
              ],
            ),
          ),
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ElevatedButton(
              onPressed: () async {
                await authService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
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

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, String route) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/transactions', arguments: {'status': label.toLowerCase()});
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Utils.mainThemeColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, String value, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, size: 24, color: color ?? Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}