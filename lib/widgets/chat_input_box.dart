import 'package:flutter/material.dart';

class ChatInputBox extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;
  final VoidCallback? onClickCamera;
  final VoidCallback? onClickMic;
  final bool isListening;
  final double? confidence;

  const ChatInputBox({
    super.key,
    this.controller,
    this.onSend,
    this.onClickCamera,
    this.onClickMic,
    this.isListening = false,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isListening)
            LinearProgressIndicator(
              value: confidence,
              backgroundColor: colorScheme.surfaceVariant,
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
              if (onClickMic != null)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: IconButton(
                    onPressed: onClickMic,
                    color: isListening ? Colors.red : colorScheme.onSecondary,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none_rounded,
                        key: ValueKey<bool>(isListening),
                      ),
                    ),
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
                  onPressed: onSend,
                  child: const Icon(Icons.send_rounded),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
