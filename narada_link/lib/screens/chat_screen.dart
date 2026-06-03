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

  // --------------------------------------------------
  // LAST SEEN FORMAT
  // --------------------------------------------------

  String formatLastSeen(String? value) {
    if (value == null || value.isEmpty) {
      return "Offline";
    }

    try {
      final dt = DateTime.parse(value).toLocal();

      int hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');

      final amPm = hour >= 12 ? "PM" : "AM";

      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return "Last seen $hour:$minute $amPm";
    } catch (_) {
      return "Offline";
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.name ?? "Narada Link User";

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff0F0F10),
                  Color(0xff151517),
                ],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,

              /// FIXED KEYBOARD JUMP
              resizeToAvoidBottomInset: false,

              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(72),
                child: _buildAppBar(displayName),
              ),

              body: SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        child: _buildMessageSection(),
                      ),
                    ),

                    _buildBottomSection(),
                  ],
                ),
              ),
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
      toolbarHeight: 72,
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
          GestureDetector(
            onTap: () {
              // TODO: Open Profile Screen
            },
            child: CircleAvatar(
              radius: 22,
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
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

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
                        _buildStatusText(),
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
            // TODO: Chat Menu
          },
        ),
      ],
    );
  }

  // --------------------------------------------------
  // STATUS TEXT
  // --------------------------------------------------

  String _buildStatusText() {
    // Future Ready
    // if (controller.isTyping) return "Typing...";
    // if (controller.isRecording) return "Recording...";

    if (controller.isOnline) {
      return "Online";
    }

    return formatLastSeen(
      controller.lastSeen,
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
  // BOTTOM SECTION
  // --------------------------------------------------

  Widget _buildBottomSection() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: const Border(
            top: BorderSide(
              color: Colors.white10,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.replyingTo != null)
              ReplyPreview(
                replyingTo: controller.replyingTo!,
                onCancel: controller.clearReply,
              ),

            ChatInputBox(
              controller: controller.textController,
              onSend: controller.sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}