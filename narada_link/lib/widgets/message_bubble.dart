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
      case "sending":
        return const Icon(
          Icons.schedule,
          size: 16,
          color: Colors.grey,
        );

      case "sent":
        return const Icon(
          Icons.check,
          size: 16,
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
            size: 16,
            color: Colors.white,
          ),
        );

      case "seen":
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.blueAccent,
        );

      case "failed":
        return const Icon(
          Icons.error_outline,
          size: 16,
          color: Colors.red,
        );

      default:
        return const Icon(
          Icons.schedule,
          size: 16,
          color: Colors.grey,
        );
    }
  }

  // --------------------------------------------------
  // FORMAT TIME
  // --------------------------------------------------

  String formatTime(String? date) {
    if (date == null || date.isEmpty) return "";

    try {
      final dt = DateTime.parse(date).toLocal();

      final hour =
          dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);

      final ampm = dt.hour >= 12 ? "PM" : "AM";

      return "$hour:${dt.minute.toString().padLeft(2, '0')} $ampm";
    } catch (_) {
      return "";
    }
  }

  // --------------------------------------------------
  // SEEN TEXT
  // --------------------------------------------------

  String buildSeenText() {
    if (widget.seenAt == null) return "";

    final seen = formatTime(widget.seenAt);

    if (seen.isEmpty) return "";

    return "Seen $seen";
  }

  // --------------------------------------------------
  // LONG PRESS MENU
  // --------------------------------------------------

  void _showMessageMenu(String text) {
    showModalBottomSheet(
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
                    ClipboardData(text: text),
                  );

                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text("Reply"),
                onTap: () {
                  Navigator.pop(context);

                  if (widget.onReply != null) {
                    widget.onReply!(widget.message);
                  }
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

    final text = widget.message["text"]?.toString() ?? "";
    final replyText = widget.message["replyText"];

    return Semantics(
      label: widget.isMe
          ? "Your message"
          : "Received message",
      child: GestureDetector(
        onLongPress: () => _showMessageMenu(text),

        // --------------------------------------------------
        // SWIPE TO REPLY
        // --------------------------------------------------

        onHorizontalDragUpdate: (details) {
          setState(() {
            dragX += details.delta.dx;

            if (widget.isMe) {
              if (dragX > 0) dragX = 0;
              if (dragX < -80) dragX = -80;
            } else {
              if (dragX < 0) dragX = 0;
              if (dragX > 80) dragX = 80;
            }
          });
        },

        onHorizontalDragEnd: (_) {
          final shouldReply =
              widget.isMe ? dragX < -50 : dragX > 50;

          if (shouldReply && widget.onReply != null) {
            HapticFeedback.lightImpact();
            widget.onReply!(widget.message);
          }

          setState(() {
            dragX = 0;
          });
        },

        child: Stack(
          children: [
            // --------------------------------------------------
            // REPLY ICON
            // --------------------------------------------------

            Positioned.fill(
              child: Align(
                alignment: widget.isMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Opacity(
                  opacity: dragX.abs() / 80,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Icon(
                      Icons.reply,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            ),

            // --------------------------------------------------
            // BUBBLE
            // --------------------------------------------------

            Transform.translate(
              offset: Offset(dragX, 0),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 150,
                ),

                margin: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),

                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),

                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width * 0.75,
                ),

                decoration: BoxDecoration(
                  color: widget.isMe
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFE0E0E0),

                  boxShadow: dragX.abs() > 20
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(
                              0.4,
                            ),
                            blurRadius: 10,
                          )
                        ]
                      : [],

                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(
                      widget.isMe ? 14 : 4,
                    ),
                    bottomRight: Radius.circular(
                      widget.isMe ? 4 : 14,
                    ),
                  ),
                ),

                child: Column(
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
                        margin: const EdgeInsets.only(
                          bottom: 6,
                        ),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.isMe
                              ? Colors.white.withOpacity(
                                  0.05,
                                )
                              : Colors.black.withOpacity(
                                  0.05,
                                ),
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
                          replyText.toString(),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle:
                                FontStyle.italic,
                            color: widget.isMe
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ),

                    // --------------------------------------------------
                    // MESSAGE TEXT
                    // --------------------------------------------------

                    SelectableText(
                      text,
                      style: TextStyle(
                        color: widget.isMe
                            ? Colors.white
                            : Colors.black,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // --------------------------------------------------
                    // TIME + STATUS
                    // --------------------------------------------------

                    Align(
                      alignment: Alignment.centerRight,
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

                          const SizedBox(width: 4),

                          Tooltip(
                            message: safeStatus,
                            child: AnimatedSwitcher(
                              duration:
                                  const Duration(
                                milliseconds: 200,
                              ),
                              child: buildTicks(
                                safeStatus,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --------------------------------------------------
                    // SEEN TIME
                    // --------------------------------------------------

                    if (widget.isMe &&
                        widget.seenAt != null &&
                        widget.seenAt!
                            .isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 2,
                        ),
                        child: Align(
                          alignment:
                              Alignment.centerRight,
                          child: Text(
                            buildSeenText(),
                            style:
                                const TextStyle(
                              fontSize: 10,
                              color: Colors
                                  .blueAccent,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}