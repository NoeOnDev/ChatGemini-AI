import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatStorage {
  static Future<void> saveChats(List<Content> chats) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> chatsEncoded =
        chats.map((chat) => jsonEncode(chat.toJson())).toList();
    await prefs.setStringList('chats', chatsEncoded);
  }

  static Future<List<Content>> loadChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? chatsEncoded = prefs.getStringList('chats');
    if (chatsEncoded != null) {
      return chatsEncoded
          .map((chatStr) => Content.fromJson(jsonDecode(chatStr)))
          .toList();
    }
    return [];
  }

  static Future<void> clearChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('chats');
  }
}
