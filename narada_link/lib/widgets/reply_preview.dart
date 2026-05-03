import 'package:flutter/material.dart';

class ReplyPreview extends StatelessWidget {
  final Map<String, dynamic> replyingTo;
  final VoidCallback onCancel;

  const ReplyPreview({
    super.key,
    required this.replyingTo,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final text = (replyingTo['text'] ?? "").toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(
            color: Colors.blueAccent,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          /// 🔹 TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Replying to",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 4),

                /// 💬 MESSAGE PREVIEW
                Text(
                  text.isNotEmpty ? text : "Message",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          /// ❌ CLOSE BUTTON
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 20,
              color: Colors.white60,
            ),
            splashRadius: 20,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}