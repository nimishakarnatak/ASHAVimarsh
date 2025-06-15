import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final Widget? extraContent;

  const ChatBubble({
    Key? key,
    required this.message,
    this.isUser = false,
    this.extraContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: isUser ? 0 : 14,
            right: isUser ? 22 : 0,
            top: isUser ? 15 : 7,
            bottom: 8,
          ),
          width: 239,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser ? const Color(0x80695BCC) : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          // child: Text(
          //   message,
          //   style: const TextStyle(
          //     fontSize: 10,
          //     color: Colors.black,
          //   ),
          // ),
          child: MarkdownBody(
            data: message,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
              code: const TextStyle(
                fontSize: 10,
                backgroundColor: Color(0xFFF5F5F5),
                color: Colors.black87,
              ),
              h1: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              h2: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              blockquote: const TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        if (extraContent != null) extraContent!,
      ],
    )
    );
  }
}
