import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/auth.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Masukkan email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Masukkan password' : null,
              ),
              SizedBox(height: 20),
              if (authService.errorMessage.isNotEmpty)
                Text(authService.errorMessage, style: TextStyle(color: Colors.red)),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool success = await authService.signInWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                    );
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/main');
                    }
                  }
                },
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text('Belum punya akun? Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}