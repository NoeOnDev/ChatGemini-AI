import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/posts_screen.dart';
import 'screens/gifts_screen.dart';
import 'screens/contact_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/gifts': (context) => const GifsScreen(),
        '/posts': (context) => const PostsScreen(),
        '/contact': (context) => ContactScreen(),
      },
    );
  }
}
