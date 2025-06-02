import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/auth.dart';
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
    setState(() {}); // Update UI saat ada perubahan
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
    final authService = Provider.of<AuthService>(context, listen: false);

    // Validasi form
    bool isFormValid = Utils.validateEmail(emailController.text.trim()) &&
        passwordController.text.trim().length >= 6 &&
        confirmPasswordController.text.trim().length >= 6 &&
        passwordController.text.trim() == confirmPasswordController.text.trim();

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255), // Latar belakang putih seperti LoginScreen
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Daftar dengan Alamat E-mail',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 40),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
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
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Kata Sandi',
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
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
                        label: 'Daftar',
                        enabled: isFormValid,
                        onTap: () async {
                          print('Mencoba registrasi dengan: ${emailController.text.trim()}, ${passwordController.text.trim()}');
                          bool accountCreated = await authService.createUserWithEmailAndPassword(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                          if (accountCreated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Registrasi berhasil!')),
                            );
                            await Future.delayed(Duration(seconds: 1)); // Delay kecil untuk menampilkan snackbar
                            Navigator.pushReplacementNamed(context, '/main'); // Langsung ke halaman home
                          }
                        },
                        backgroundColor: Utils.mainThemeColor,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Sudah punya akun? ",
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            child: Text(
                              "Masuk sekarang",
                              style: TextStyle(color: Utils.mainThemeColor, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (authService.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      authService.errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}