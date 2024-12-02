import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'screens/chat_screen.dart';
import 'screens/home_screen.dart';
import 'screens/test_location.dart';

void main() async {
  Gemini.init(apiKey: 'AIzaSyB6zT53eMugA47fm2w3qaPinBQPp2w9ZBc');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gemini',
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          cardTheme: CardTheme(color: Colors.blue.shade900)),
      initialRoute: '/',
      routes: {
        '/': (context) => const TestLocationScreen(),
        '/profile': (context) => const HomeScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
