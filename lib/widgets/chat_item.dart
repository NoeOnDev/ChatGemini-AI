import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatItem extends StatelessWidget {
  final Content content;

  const ChatItem({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
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
