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

  // --------------------------------------------------
  // DATE HELPERS
  // --------------------------------------------------

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final yesterday = today.subtract(
      const Duration(days: 1),
    );

    final target = DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (target == today) {
      return "Today";
    }

    if (target == yesterday) {
      return "Yesterday";
    }

    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildDateChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 60,
            color: Colors.white24,
          ),
          SizedBox(height: 12),
          Text(
            "No messages yet",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Say Hi 👋",
            style: TextStyle(
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),

      child: ListView.builder(
        key: ValueKey(messages.length),

        controller: scrollController,

        // backend oldest -> newest
        reverse: false,

        padding: const EdgeInsets.only(
          top: 18,
          bottom: 8,
          left: 10,
          right: 10,
        ),

        itemCount: messages.length,

        itemBuilder: (context, index) {
          final m = messages[index];

          final currentSender =
              m['senderId']?.toString();

          final isMe =
              currentSender == myId;

          // ----------------------------
          // GROUPING
          // ----------------------------

          final previousSender =
              index > 0
                  ? messages[index - 1]
                          ['senderId']
                      ?.toString()
                  : null;

          final isSameSender =
              currentSender ==
                  previousSender;

          // ----------------------------
          // DATE HEADER
          // ----------------------------

          bool showDateHeader = false;

          final currentDate =
              _parseDate(
            m['createdAt'],
          );

          if (currentDate != null) {
            if (index == 0) {
              showDateHeader = true;
            } else {
              final previousDate =
                  _parseDate(
                messages[index - 1]
                    ['createdAt'],
              );

              if (previousDate == null ||
                  !_isSameDay(
                    currentDate,
                    previousDate,
                  )) {
                showDateHeader = true;
              }
            }
          }

          return Column(
            children: [
              if (showDateHeader)
                _buildDateChip(
                  _formatDateLabel(
                    currentDate!,
                  ),
                ),

              Padding(
                padding: EdgeInsets.only(
                  top: isSameSender
                      ? 2
                      : 10,
                ),

                child: MessageBubble(
                  key: ValueKey(
                    m['_id'] ??
                        "${m['senderId']}_$index",
                  ),

                  message: m,

                  isMe: isMe,

                  status: m['status']
                      ?.toString(),

                  createdAt:
                      m['createdAt']
                          ?.toString(),

                  seenAt: m['seenAt']
                      ?.toString(),

                  onReply: onReply,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}