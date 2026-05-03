import 'socket_service.dart';

class HomeSocketService {
  final String myId;
  final SocketService socket;

  HomeSocketService({
    required this.myId,
    required this.socket,
  });

  /// 🔌 CONNECT
  void connect() {
    socket.connect(userId: myId);
  }

  /// 📩 NEW MESSAGE
  void onNewMessage({
    required Function(dynamic data) onMessage,
  }) {
    socket.onNewMessage((data) {
      onMessage(data);
    });
  }

  /// 👀 BULK SEEN
  void onMessagesSeen({
    required Function(List<String> ids) onSeen,
  }) {
    socket.onMessagesSeen((data) {
      final ids = List<String>.from(data['messageIds'] ?? []);
      onSeen(ids);
    });
  }

  /// 🔄 PROFILE UPDATE
  void onUserUpdated({
    required Function() onUpdate,
  }) {
    socket.onUserUpdated((_) {
      onUpdate();
    });
  }

  /// 🟢 USER STATUS
  void onUserStatus({
    required Function(String userId, bool isOnline, String? lastSeen) onStatus,
  }) {
    socket.onUserStatus((data) {
      onStatus(
        data['userId'].toString(),
        data['isOnline'] ?? false,
        data['lastSeen'],
      );
    });
  }

  /// 🔌 DISCONNECT
  void disconnect() {
    socket.disconnect();
  }
}