import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/auth.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Akun'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(authService.currentUser?.email ?? 'Belum login'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}