import 'sections/chat_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedLanguage = 'Español';

  final _languages = ['Español', 'Inglés'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Flutter Gemini - $_selectedLanguage'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedLanguage,
            onSelected: (value) => setState(() => _selectedLanguage = value),
            itemBuilder: (context) => _languages.map((language) {
              return PopupMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            child: const Icon(Icons.language),
          )
        ],
      ),
      body: SectionStreamChat(language: _selectedLanguage),
    );
  }
}
