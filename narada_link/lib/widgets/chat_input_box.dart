import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ChatInputBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputBox({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: AppColors.primary,
              ),
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}