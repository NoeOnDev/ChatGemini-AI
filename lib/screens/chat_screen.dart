import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
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

  void _showClearChatsDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Eliminar Chats',
      desc: '¿Estás seguro de que deseas eliminar todos los chats?',
      btnCancelOnPress: () {},
      btnOkOnPress: _clearChats,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Chat-Gemini - $_selectedLanguage'),
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
            icon: const Icon(Icons.delete_forever),
            onPressed: _showClearChatsDialog,
            tooltip: 'Clear Chats',
          ),
        ],
      ),
      body: SectionStreamChat(
          language: _selectedLanguage, chatsNotifier: _chatsNotifier),
    );
  }
}
