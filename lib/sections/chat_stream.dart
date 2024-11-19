import 'dart:typed_data';
import '/widgets/chat_input_box.dart';
import '/widgets/item_image_view.dart';
import '/widgets/chat_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '/utils/connectivity_service.dart';
import '/utils/chat_storage.dart';

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
  final FlutterTts flutterTts = FlutterTts();

  bool _loading = false;
  bool _isListening = false;
  bool _isConnected = true;
  List<Uint8List>? images;
  String accumulatedResponse = '';

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
    _configureTts();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _configureTts() async {
    await flutterTts
        .setLanguage(widget.language == 'Español' ? 'es-ES' : 'en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _saveChats() async {
    await ChatStorage.saveChats(widget.chatsNotifier.value);
  }

  Future<void> _loadChats() async {
    final loadedChats = await ChatStorage.loadChats();
    setState(() {
      widget.chatsNotifier.value = loadedChats;
    });
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
                          itemBuilder: (context, index) =>
                              ChatItem(content: chats[index]),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chats.length,
                          reverse: false,
                        ),
                      ),
                    )
                  : const Center(child: Text('Start a conversation'));
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
                  ? "$searchedText. Por favor responde en español. Necesito que me ayudes a practicar español. Responde solo en español."
                  : "$searchedText. Please answer in English. I need you to help me practice English. Respond only in English.";

              widget.chatsNotifier.value.add(
                Content(role: 'user', parts: [Parts(text: searchedText)]),
              );
              controller.clear();
              loading = true;
              accumulatedResponse = '';

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
                    accumulatedResponse += value.output ?? '';
                  });
                  _saveChats();
                }, onDone: () {
                  _speak(accumulatedResponse);
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
                    accumulatedResponse += value.output ?? '';
                  });
                  _saveChats();
                }, onDone: () {
                  _speak(accumulatedResponse);
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
}
