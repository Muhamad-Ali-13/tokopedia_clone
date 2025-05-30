import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/screens/splash_screen.dart';
import 'package:tokopedia_clone/services/login_service.dart';
import 'package:tokopedia_clone/screens/home_screen.dart';
import 'package:tokopedia_clone/providers/cart.dart';
import 'package:tokopedia_clone/screens/cart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDqTCTZH0ErjeQEUz-tG2kxed8n2G31usA",
      authDomain: "tokopediaclone-43eb0.firebaseapp.com",
      projectId: "tokopediaclone-43eb0",
      storageBucket: "tokopediaclone-43eb0.firebasestorage.app",
      messagingSenderId: "477540393781",
      appId: "1:477540393781:web:ade7b42a2f0ecede0aa27c",
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginService()),
        ChangeNotifierProvider(create: (_) => Cart()), // Pastikan Cart ada
      ],
      child: TokopediaCloneApp(),
    ),
  );
}

class TokopediaCloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tokopedia Clone',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/cart': (context) => CartScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}