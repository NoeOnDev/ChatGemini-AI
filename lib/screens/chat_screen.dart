import 'package:flutter/material.dart';
import '../sections/chat_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _selectedLanguage = 'Español';
  final _languages = ['Español', 'Inglés'];
  final ValueNotifier<List<Content>> _chatsNotifier =
      ValueNotifier<List<Content>>([]);

  Future<void> _clearChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('chats');
    _chatsNotifier.value = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Flutter Gemini - $_selectedLanguage'),
        actions: [
          PopupMenuButton(
            initialValue: _selectedLanguage,
            onSelected: (value) => setState(() => _selectedLanguage = value),
            itemBuilder: (context) => _languages.map((language) {
              return PopupMenuItem(
                value: language,
                child: Text(language),
              );
            }).toList(),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.language),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearChats,
            tooltip: 'Clear Chats',
          ),
        ],
      ),
      body: SectionStreamChat(
          language: _selectedLanguage, chatsNotifier: _chatsNotifier),
    );
  }
}
