import 'dart:typed_data';
import 'dart:convert';
import '/widgets/chat_input_box.dart';
import '/widgets/item_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '/utils/connectivity_service.dart';

class SectionStreamChat extends StatefulWidget {
  final String language;
  final ValueNotifier<List<Content>> chatsNotifier;

  const SectionStreamChat(
      {super.key, required this.language, required this.chatsNotifier});

  @override
  State<SectionStreamChat> createState() => _SectionStreamChatState();
}

class _SectionStreamChatState extends State<SectionStreamChat> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  final ImagePicker picker = ImagePicker();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _loading = false;
  bool _isListening = false;
  bool _isConnected = true;
  List<Uint8List>? images;

  bool get loading => _loading;
  set loading(bool set) => setState(() => _loading = set);

  final int maxChatHistoryLength = 10;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _connectivityService.connectivityStream.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  Future<void> _saveChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> chatsEncoded = widget.chatsNotifier.value
        .map((chat) => jsonEncode(chat.toJson()))
        .toList();
    await prefs.setStringList('chats', chatsEncoded);
  }

  Future<void> _loadChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? chatsEncoded = prefs.getStringList('chats');
    if (chatsEncoded != null) {
      setState(() {
        widget.chatsNotifier.value = chatsEncoded
            .map((chatStr) => Content.fromJson(jsonDecode(chatStr)))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder<List<Content>>(
            valueListenable: widget.chatsNotifier,
            builder: (context, chats, _) {
              return chats.isNotEmpty
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        reverse: true,
                        child: ListView.builder(
                          itemBuilder: chatItem,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chats.length,
                          reverse: false,
                        ),
                      ),
                    )
                  : const Center(child: Text('Search something!'));
            },
          ),
        ),
        if (loading)
          Center(
            child: Lottie.asset(
              'assets/lottie/ai.json',
              fit: BoxFit.fill,
            ),
          ),
        if (images != null)
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.centerLeft,
            child: Card(
              child: ListView.builder(
                itemBuilder: (context, index) => ItemImageView(
                  bytes: images!.elementAt(index),
                ),
                itemCount: images!.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
        ChatInputBox(
          controller: controller,
          onClickCamera: () {
            picker.pickMultiImage().then((value) async {
              final imagesBytes = <Uint8List>[];
              for (final file in value) {
                imagesBytes.add(await file.readAsBytes());
              }

              if (imagesBytes.isNotEmpty) {
                setState(() {
                  images = imagesBytes;
                });
              }
            });
          },
          isListening: _isListening,
          onSend: () {
            if (controller.text.isNotEmpty) {
              final searchedText = controller.text;

              final promptWithLanguageHint = widget.language == 'Español'
                  ? "$searchedText. Por favor responde en inglés, necesito que me ayudes a practicar inglés."
                  : "$searchedText. Please answer in English, I need you to help me practice English.";

              widget.chatsNotifier.value.add(
                Content(role: 'user', parts: [Parts(text: searchedText)]),
              );
              controller.clear();
              loading = true;

              if (images != null) {
                gemini
                    .streamGenerateContent(
                  promptWithLanguageHint,
                  images: images,
                )
                    .listen((value) {
                  loading = false;
                  setState(() {
                    if (widget.chatsNotifier.value.isNotEmpty &&
                        widget.chatsNotifier.value.last.role ==
                            value.content?.role) {
                      widget.chatsNotifier.value.last.parts!.last.text =
                          '${widget.chatsNotifier.value.last.parts!.last.text}${value.output}';
                    } else {
                      widget.chatsNotifier.value.add(Content(
                          role: 'model', parts: [Parts(text: value.output)]));
                    }
                  });
                  _saveChats();
                  setState(() {
                    images = null;
                  });
                });
              } else {
                final recentChats =
                    widget.chatsNotifier.value.length > maxChatHistoryLength
                        ? widget.chatsNotifier.value.sublist(
                            widget.chatsNotifier.value.length -
                                maxChatHistoryLength)
                        : widget.chatsNotifier.value;

                gemini.streamChat(recentChats).listen((value) {
                  loading = false;
                  setState(() {
                    if (widget.chatsNotifier.value.isNotEmpty &&
                        widget.chatsNotifier.value.last.role ==
                            value.content?.role) {
                      widget.chatsNotifier.value.last.parts!.last.text =
                          '${widget.chatsNotifier.value.last.parts!.last.text}${value.output}';
                    } else {
                      widget.chatsNotifier.value.add(Content(
                          role: 'model', parts: [Parts(text: value.output)]));
                    }
                  });
                  _saveChats();
                });
              }
            }
          },
          language: widget.language,
          onListeningChanged: (isListening) {
            setState(() {
              _isListening = isListening;
            });
          },
          isConnected: _isConnected,
        ),
      ],
    );
  }

  Widget chatItem(BuildContext context, int index) {
    final Content content = widget.chatsNotifier.value[index];

    return Card(
      elevation: 0,
      color:
          content.role == 'model' ? Colors.blue.shade800 : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor:
                  content.role == 'model' ? Colors.blue : Colors.grey,
              child: content.role == 'model'
                  ? Transform.translate(
                      offset: const Offset(-2, -2),
                      child: const Icon(
                        FontAwesomeIcons.robot,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : const Icon(
                      FontAwesomeIcons.user,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Markdown(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    data: content.parts?.lastOrNull?.text ??
                        'cannot generate data!',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
