import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tokopedia_clone/providers/auth.dart';
import 'package:tokopedia_clone/providers/cart.dart';
import 'package:tokopedia_clone/screens/splash_screen.dart';
import 'package:tokopedia_clone/screens/login_screen.dart';
import 'package:tokopedia_clone/screens/register_screen.dart';
import 'package:tokopedia_clone/screens/home_screen.dart';
import 'package:tokopedia_clone/screens/product_detail_screen.dart';
import 'package:tokopedia_clone/screens/cart_screen.dart';
import 'package:tokopedia_clone/screens/checkout_screen.dart';
import 'package:tokopedia_clone/screens/transaction_screen.dart';
import 'package:tokopedia_clone/screens/video_screen.dart';
import 'package:tokopedia_clone/screens/promo_screen.dart';
import 'package:tokopedia_clone/screens/account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
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
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => Cart()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tokopedia Clone',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/main': (context) => MainScreen(),
        '/product_detail': (context) => ProductDetailScreen(),
        '/cart': (context) => CartScreen(),
        '/checkout': (context) => CheckoutScreen(),
        '/transactions': (context) => TransactionScreen(),
        '/video': (context) => VideoScreen(),
        '/promo': (context) => PromoScreen(),
        '/account': (context) => AccountScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    VideoScreen(),
    PromoScreen(),
    TransactionScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Video'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Promo'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Akun'),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}