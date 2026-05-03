import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ChatTile extends StatelessWidget {
  final Map chat;
  final String myId;
  final Function() onTap;
  final String time;
  final String statusText;

  const ChatTile({
    super.key,
    required this.chat,
    required this.myId,
    required this.onTap,
    required this.time,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final userId = chat['userId'];
    final name = (chat['name'] ?? "Narada Link User").toString();
    final avatar = chat['avatar'];

    final unread = chat['unreadCount'] ?? 0;
    final isOnline = chat['isOnline'] == true;

    final lastMessageRaw = (chat['lastMessage'] ?? "").toString();
    final isMe = chat['senderId']?.toString() == myId;

    final lastMessage =
        isMe ? "You: $lastMessageRaw" : lastMessageRaw;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            /// 👤 AVATAR + ONLINE DOT
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.input,
                  backgroundImage: avatar != null &&
                          avatar.toString().isNotEmpty
                      ? NetworkImage(avatar)
                      : null,
                  child: (avatar == null ||
                          avatar.toString().isEmpty)
                      ? Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase()
                              : "U",
                          style: const TextStyle(
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color:
                          isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.card,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            /// 💬 TEXT SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: unread > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),

                  const SizedBox(height: 2),

                  /// STATUS
                  Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// MESSAGE + UNREAD
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontWeight: unread > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),

                      if (unread > 0)
                        Container(
                          margin:
                              const EdgeInsets.only(left: 6),
                          padding:
                              const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            /// ⏱ TIME
            Text(
              time,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}