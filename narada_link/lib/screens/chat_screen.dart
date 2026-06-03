import 'package:flutter/material.dart';

import '../controllers/chat_controller.dart';
import '../utils/colors.dart';
import '../widgets/chat_input_box.dart';
import '../widgets/chat_message_list.dart';
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
    )..init();
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
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(displayName),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildMessageSection(),
                ),

                if (controller.replyingTo != null)
                  _buildReplyPreview(),

                _buildInputArea(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // APP BAR
  // --------------------------------------------------

  PreferredSizeWidget _buildAppBar(String displayName) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,

      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),

      titleSpacing: 0,

      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade800,
            child: Text(
              displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : "U",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Row(
                  children: [
                    if (controller.isOnline)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),

                    if (controller.isOnline)
                      const SizedBox(width: 6),

                    Flexible(
                      child: Text(
                        controller.isOnline
                            ? "Online"
                            : (controller.lastSeen ?? "Offline"),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Chat options menu
          },
        ),
      ],
    );
  }

  // --------------------------------------------------
  // MESSAGE SECTION
  // --------------------------------------------------

  Widget _buildMessageSection() {
    if (controller.messages.isEmpty) {
      return const Center(
        child: Text(
          "Start Conversation 👋",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      );
    }

    return ChatMessageList(
      messages: controller.messages,
      myId: widget.myId,
      scrollController: controller.scrollController,
      onReply: controller.setReply,
    );
  }

  // --------------------------------------------------
  // REPLY PREVIEW
  // --------------------------------------------------

  Widget _buildReplyPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        border: const Border(
          top: BorderSide(
            color: Colors.white10,
          ),
        ),
      ),
      child: ReplyPreview(
        replyingTo: controller.replyingTo!,
        onCancel: controller.clearReply,
      ),
    );
  }

  // --------------------------------------------------
  // INPUT AREA
  // --------------------------------------------------

  Widget _buildInputArea(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white10,
            ),
          ),
        ),
        child: ChatInputBox(
          controller: controller.textController,
          onSend: controller.sendMessage,
        ),
      ),
    );
  }
}