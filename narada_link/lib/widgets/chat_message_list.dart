import 'package:flutter/material.dart';
import 'message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final String myId;
  final ScrollController scrollController;
  final Function(Map<String, dynamic>) onReply;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.myId,
    required this.scrollController,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final reversedMessages = messages.reversed.toList();

    if (messages.isEmpty) {
      return const Center(
        child: Text(
          "Start conversation 👋",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.all(10),
      itemCount: reversedMessages.length,
      itemBuilder: (context, index) {
        final m = reversedMessages[index];

        final isMe = m['senderId'].toString() == myId;

        return MessageBubble(
          message: m,
          isMe: isMe,
          onReply: onReply,
        );
      },
    );
  }
}