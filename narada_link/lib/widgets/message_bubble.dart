import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageBubble extends StatefulWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  final String? status;
  final String? createdAt;
  final String? seenAt;

  final Function(Map<String, dynamic>)? onReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.status,
    this.createdAt,
    this.seenAt,
    this.onReply,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  double dragX = 0;

  // --------------------------------------------------
  // STATUS TICKS
  // --------------------------------------------------

  Widget buildTicks(String status) {
    if (!widget.isMe) return const SizedBox();

    switch (status) {
      case "sent":
        return const Icon(
          Icons.check,
          size: 15,
          color: Colors.grey,
        );

      case "delivered":
        return ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Colors.purple,
              Colors.deepPurple,
            ],
          ).createShader(bounds),
          child: const Icon(
            Icons.done_all,
            size: 15,
            color: Colors.white,
          ),
        );

      case "seen":
        return const Icon(
          Icons.done_all,
          size: 15,
          color: Colors.blueAccent,
        );

      default:
        return const Icon(
          Icons.schedule,
          size: 15,
          color: Colors.grey,
        );
    }
  }

  // --------------------------------------------------
  // TIME FORMAT
  // --------------------------------------------------

  String formatTime(String? date) {
    if (date == null || date.isEmpty) return "";

    try {
      final dt = DateTime.parse(date).toLocal();

      int hour = dt.hour;

      if (hour > 12) {
        hour -= 12;
      }

      if (hour == 0) {
        hour = 12;
      }

      final ampm = dt.hour >= 12 ? "PM" : "AM";

      return "$hour:${dt.minute.toString().padLeft(2, '0')} $ampm";
    } catch (_) {
      return "";
    }
  }

  // --------------------------------------------------
  // LONG PRESS MENU
  // --------------------------------------------------

  Future<void> _showMessageMenu() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text("Copy"),
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: widget.message["text"] ?? "",
                    ),
                  );

                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text("Reply"),
                onTap: () {
                  Navigator.pop(context);

                  widget.onReply?.call(widget.message);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeStatus = widget.status ?? "sent";

    final text = widget.message["text"] ?? "";

    final replyText = widget.message["replyText"];

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // --------------------------------------------------
        // SWIPE REPLY INDICATOR
        // --------------------------------------------------

        if (dragX > 20)
          const Positioned(
            left: 16,
            child: Icon(
              Icons.reply,
              size: 24,
            ),
          ),

        // --------------------------------------------------
        // MESSAGE
        // --------------------------------------------------

        GestureDetector(
          onLongPress: _showMessageMenu,

          onHorizontalDragUpdate: (details) {
            setState(() {
              dragX += details.delta.dx;

              if (dragX < 0) dragX = 0;
              if (dragX > 80) dragX = 80;
            });
          },

          onHorizontalDragEnd: (_) {
            if (dragX > 50) {
              widget.onReply?.call(widget.message);
            }

            setState(() {
              dragX = 0;
            });
          },

          child: Align(
            alignment: widget.isMe
                ? Alignment.centerRight
                : Alignment.centerLeft,

            child: Transform.translate(
              offset: Offset(dragX, 0),

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),

                margin: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),

                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),

                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width * 0.75,
                ),

                decoration: BoxDecoration(
                  color: widget.isMe
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFE0E0E0),

                  boxShadow: dragX > 20
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.25),
                            blurRadius: 10,
                          )
                        ]
                      : [],

                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),

                    // Bubble Tail Feel

                    bottomLeft: Radius.circular(
                      widget.isMe ? 14 : 2,
                    ),

                    bottomRight: Radius.circular(
                      widget.isMe ? 2 : 14,
                    ),
                  ),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // --------------------------------------------------
                    // REPLY PREVIEW
                    // --------------------------------------------------

                    if (replyText != null &&
                        replyText.toString().isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin:
                            const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.isMe
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          border: const Border(
                            left: BorderSide(
                              color: Colors.blueAccent,
                              width: 3,
                            ),
                          ),
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                        child: Text(
                          replyText,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: widget.isMe
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ),

                    // --------------------------------------------------
                    // MESSAGE + TIME
                    // --------------------------------------------------

                    Stack(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(
                            right: 60,
                            bottom: 16,
                          ),
                          child: SelectableText(
                            text,
                            style: TextStyle(
                              color: widget.isMe
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 15.5,
                              height: 1.3,
                            ),
                          ),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Text(
                                formatTime(
                                  widget.createdAt,
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.isMe
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),

                              if (widget.isMe)
                                const SizedBox(
                                  width: 4,
                                ),

                              buildTicks(
                                safeStatus,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}