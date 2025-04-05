import 'package:flutter/material.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'friends_page.dart'; // <- Import FriendsPage
import 'home_screen.dart'; // <- Import HomeScreen
import 'history_screen.dart';

void main() {
  runApp(const ChakraClashApp());
}

class ChakraClashApp extends StatelessWidget {
  const ChakraClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChakraClash',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/friends': (context) => const FriendsPage(), // <- Route to FriendsPage
        '/home': (context) => HomeScreen(), // <- Route to HomeScreen
        '/history': (context) =>  HistoryScreen(), // <- Route to HistoryScreen
      },
    );
  }
}
