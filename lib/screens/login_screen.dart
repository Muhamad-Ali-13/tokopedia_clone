import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/screens/register_screen.dart';
import 'package:tokopedia_clone/services/login_service.dart';
import 'package:tokopedia_clone/utils/utils.dart';
import 'package:tokopedia_clone/widgets/main_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_updateState);
    passwordController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context, listen: false);

    bool isFormValid = Utils.validateEmail(emailController.text.trim()) &&
        passwordController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Icon(Icons.store, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              'Masuk ke Tokopedia',
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
                labelText: 'Kata Sandi',
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
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fitur Forgot Password belum diimplementasi')),
                  );
                },
                child: Text('Forgot password?', style: TextStyle(color: Colors.green)),
              ),
            ),
            SizedBox(height: 20),
            MainButton(
              label: 'Sign in',
              enabled: isFormValid,
              onTap: () async {
                bool isLoggedIn = await loginService.signInWithEmailAndPassword(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
                if (isLoggedIn) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              backgroundColor: Colors.green,
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: Text(
                "Don't have an account? Sign up now",
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