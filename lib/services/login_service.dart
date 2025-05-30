import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LoginService extends ChangeNotifier {
  String _userId = '';
  String _errorMessage = '';
  String _successMessage = ''; // Tambahan buat pesan sukses

  String getErrorMessage() => _errorMessage;
  String getUserId() => _userId;
  String getSuccessMessage() => _successMessage; // Getter buat pesan sukses

  void setLoginErrorMessage(String msg) {
    _errorMessage = msg;
    _successMessage = ''; // Reset pesan sukses kalo ada error
    notifyListeners();
  }

  void setSuccessMessage(String msg) {
    _successMessage = msg;
    _errorMessage = ''; // Reset pesan error kalo sukses
    notifyListeners();
  }

  Future<bool> createUserWithEmailAndPassword(String email, String pwd) async {
    // Validasi input sebelum kirim ke Firebase
    if (email.isEmpty || pwd.isEmpty) {
      setLoginErrorMessage('Email dan password tidak boleh kosong');
      return false;
    }
    if (pwd.length < 6) {
      setLoginErrorMessage('Password minimal 6 karakter');
      return false;
    }

    try {
      UserCredential userCredentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email.trim(), password: pwd.trim());
      if (userCredentials.user != null) {
        _userId = userCredentials.user!.uid;
        setSuccessMessage('Registrasi berhasil! Silakan login.');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (ex) {
      setLoginErrorMessage('Error saat registrasi: ${ex.message}');
      return false;
    } catch (e) {
      setLoginErrorMessage('Terjadi kesalahan: $e');
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    // Validasi input sebelum kirim ke Firebase
    if (email.isEmpty || password.isEmpty) {
      setLoginErrorMessage('Email dan password tidak boleh kosong');
      return false;
    }
    if (password.length < 6) {
      setLoginErrorMessage('Password minimal 6 karakter');
      return false;
    }

    try {
      UserCredential credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      if (credentials.user != null) {
        _userId = credentials.user!.uid;
        setSuccessMessage('Login berhasil!');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (ex) {
      setLoginErrorMessage('Error saat login: ${ex.message}');
      return false;
    } catch (e) {
      setLoginErrorMessage('Terjadi kesalahan: $e');
      return false;
    }
  }

  // Fungsi tambahan untuk logout (opsional, bisa dipakai nanti)
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _userId = '';
      _errorMessage = '';
      _successMessage = 'Logout berhasil';
      notifyListeners();
    } catch (e) {
      setLoginErrorMessage('Error saat logout: $e');
    }
  }
}