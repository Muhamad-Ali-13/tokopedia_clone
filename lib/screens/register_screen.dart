import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/services/login_service.dart';
import 'package:tokopedia_clone/utils/utils.dart';
import 'package:tokopedia_clone/widgets/main_button.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true; // Toggle password visibility
  bool _obscureConfirmPassword = true; // Toggle confirm password visibility

  @override
  void initState() {
    super.initState();
    emailController.addListener(_updateState);
    passwordController.addListener(_updateState);
    confirmPasswordController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {}); // Update UI pas ada perubahan
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: false);

    // Validasi form
    bool isFormValid = Utils.validateEmail(emailController.text.trim()) &&
        passwordController.text.trim().length >= 6 &&
        confirmPasswordController.text.trim().length >= 6 &&
        passwordController.text.trim() == confirmPasswordController.text.trim();

    return Scaffold(
      backgroundColor: Colors.lightGreen[50], // Mirip LoginScreen
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50), // Jarak dari atas
            Icon(Icons.store, color: Colors.green, size: 80), // Logo Tokopedia
            SizedBox(height: 20),
            Text(
              'Create New Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
            ),
            SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
            ),
            SizedBox(height: 20),
            MainButton(
              label: 'Register',
              enabled: isFormValid,
              onTap: () async {
                print('Mencoba registrasi dengan: ${emailController.text.trim()}, ${passwordController.text.trim()}');
                bool accountCreated = await loginService.createUserWithEmailAndPassword(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
                if (accountCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
                  );
                  Navigator.pop(context); // Kembali ke LoginScreen
                }
              },
              backgroundColor: Colors.green,
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Kembali ke LoginScreen
              },
              child: Text(
                'Already have an account? Sign in',
                style: TextStyle(color: Colors.green),
              ),
            ),
            Consumer<LoginService>(
              builder: (context, lService, child) {
                String errorMsg = lService.getErrorMessage();
                String successMsg = lService.getSuccessMessage();
                if (errorMsg.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 10),
                        Expanded(child: Text(errorMsg, style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                }
                if (successMsg.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 10),
                        Expanded(child: Text(successMsg, style: TextStyle(color: Colors.green))),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}