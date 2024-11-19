import 'package:flutter/material.dart';
import 'package:test_example/sections/voice_input.dart';

class ChatInputBox extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;
  final VoidCallback? onClickCamera;
  final bool isListening;
  final double? confidence;
  final Function(bool isListening)? onListeningChanged;
  final String language;
  final bool isConnected;

  const ChatInputBox({
    super.key,
    this.controller,
    this.onSend,
    this.onClickCamera,
    this.isListening = false,
    this.confidence,
    this.onListeningChanged,
    required this.language,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isConnected)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red,
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'No internet connection',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          if (isListening)
            LinearProgressIndicator(
              value: confidence,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                  confidence != null && confidence! > 0.8
                      ? Colors.green
                      : colorScheme.primary),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (onClickCamera != null)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: IconButton(
                    onPressed: onClickCamera,
                    color: colorScheme.onSecondary,
                    icon: const Icon(Icons.file_copy_rounded),
                  ),
                ),
              if (controller != null && onListeningChanged != null)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: VoiceInput(
                    controller: controller!,
                    onListeningChanged: onListeningChanged!,
                    language: language,
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 6,
                  cursorColor: colorScheme.inversePrimary,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  enabled: !isListening,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    hintText: isListening ? 'Listening...' : 'Message',
                    border: InputBorder.none,
                  ),
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: FloatingActionButton.small(
                  onPressed: isConnected ? onSend : null,
                  child: Icon(
                    isConnected ? Icons.send_rounded : Icons.desktop_access_disabled,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
