import 'package:flutter/material.dart';

import '../utils/colors.dart';

// ✅ controller
import '../controllers/chat_controller.dart';

// ✅ widgets
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input_box.dart';
import '../widgets/reply_preview.dart';

class ChatScreen extends StatefulWidget {
  final String jwt;
  final String userId;
  final String myId;
  final String? name;

  const ChatScreen({
    super.key,
    required this.jwt,
    required this.userId,
    required this.myId,
    this.name,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController controller;

  @override
  void initState() {
    super.initState();

    controller = ChatController(
      jwt: widget.jwt,
      userId: widget.userId,
      myId: widget.myId,
    );

    controller.init();
  }

  @override
  void dispose() {
    controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.name ?? "Narada Link User";

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,

          /// 🔝 APP BAR
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName),

                /// 🟢 STATUS
                Text(
                  controller.isOnline
                      ? "Online"
                      : controller.lastSeen ?? "",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          /// 📱 BODY
          body: Column(
            children: [
              /// 💬 MESSAGE LIST
              Expanded(
                child: ChatMessageList(
                  messages: controller.messages,
                  myId: widget.myId,
                  scrollController: controller.scrollController,
                  onReply: controller.setReply,
                ),
              ),

              /// 🔁 REPLY PREVIEW
              if (controller.replyingTo != null)
                ReplyPreview(
                  replyingTo: controller.replyingTo!,
                  onCancel: controller.clearReply, // ✅ correct
                ),

              /// ✉️ INPUT BOX
              ChatInputBox(
                controller: controller.textController,
                onSend: controller.sendMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}