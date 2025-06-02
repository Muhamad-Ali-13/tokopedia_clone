import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = '';
  String _successMessage = '';

  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  User? get currentUser => _auth.currentUser;

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _errorMessage = '';
      _successMessage = 'Login berhasil!';
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Terjadi kesalahan';
      _successMessage = '';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _errorMessage = '';
      _successMessage = 'Registrasi berhasil!';
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Terjadi kesalahan';
      _successMessage = '';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}