import '../services/socket_service.dart';

class ChatSocketService {
  final SocketService socket;

  ChatSocketService(this.socket);

  /// 🔌 INIT (CONNECT + JOIN)
  void init(String myId) {
    socket.connect(userId: myId);
    socket.socket?.emit("join", myId);
  }

  /// 👀 SEND SEEN
  void sendSeen(String senderId) {
    socket.sendSeen(senderId: senderId);
  }

  /// 📩 NEW MESSAGE
  void onNewMessage({
    required String myId,
    required String chatUserId,
    required Function(Map<String, dynamic>) onMessage,
  }) {
    socket.onNewMessage((data) {
      final senderId = data['senderId']?.toString() ?? "";

      if (senderId == myId) return;

      if (senderId == chatUserId) {
        onMessage({
          "_id": data['messageId'],
          "senderId": senderId,
          "receiverId": myId,
          "text": data['text'],
          "createdAt": data['createdAt'],
          "status": data['status'] ?? "sent",
          "seenAt": null,
          "replyTo": data['replyTo'],
          "replyText": data['replyText'],
          "replySenderId": data['replySenderId'],
        });
      }
    });
  }

  /// 👀 BULK SEEN
  void onMessagesSeen({
    required Function(List<String> ids, dynamic seenAt) onSeen,
  }) {
    socket.onMessagesSeen((data) {
      final ids = List<String>.from(data['messageIds'] ?? []);
      final seenAt = data['seenAt'];

      onSeen(ids, seenAt);
    });
  }

  /// 📦 DELIVERED
  void onDelivered({
    required Function(String messageId) onDelivered,
  }) {
    socket.socket?.on("messageDelivered", (data) {
      final messageId = data['messageId']?.toString();

      if (messageId != null) {
        onDelivered(messageId);
      }
    });
  }

  /// 🟢 USER STATUS
  void onUserStatus({
    required String chatUserId,
    required Function(bool isOnline, String? lastSeen) onStatus,
  }) {
    socket.onUserStatus((data) {
      if (data['userId'] == chatUserId) {
        onStatus(
          data['isOnline'] ?? false,
          data['lastSeen'],
        );
      }
    });
  }

  /// 🧹 CLEANUP (VERY IMPORTANT)
  void dispose() {
    socket.socket?.off("newMessage");
    socket.socket?.off("messageDelivered");
    socket.socket?.off("messagesSeen");
    socket.socket?.off("userStatus");

    socket.disconnect();
  }
}