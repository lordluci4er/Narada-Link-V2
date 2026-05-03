import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class HomeController extends ChangeNotifier {
  final String jwt;
  final String myId;

  HomeController({
    required this.jwt,
    required this.myId,
  });

  /// 🔌 SOCKET
  final socket = SocketService();

  /// 📦 STATE
  List chats = [];
  bool loading = false;

  /// 🚀 INIT
  void init() {
    loadChats();

    socket.connect(userId: myId);

    _listenSocket();
  }

  /// 🎧 SOCKET LISTENERS
  void _listenSocket() {
    /// 📩 NEW MESSAGE
    socket.onNewMessage((data) {
      updateChatList(data);
    });

    /// 👀 BULK SEEN
    socket.onMessagesSeen((data) {
      final ids = List<String>.from(data['messageIds'] ?? []);

      for (var chat in chats) {
        chat['unreadCount'] = 0;
      }

      notifyListeners();
    });

    /// 🔄 PROFILE UPDATE
    socket.onUserUpdated((_) {
      loadChats();
    });

    /// 🟢 ONLINE STATUS
    socket.onUserStatus((data) {
      final userId = data['userId'];

      final index = chats.indexWhere(
        (c) => c['userId'].toString() == userId.toString(),
      );

      if (index != -1) {
        chats[index]['isOnline'] = data['isOnline'] ?? false;
        chats[index]['lastSeen'] = data['lastSeen'];
        notifyListeners();
      }
    });
  }

  /// 🔥 LOAD CHATS
  Future<void> loadChats() async {
    loading = true;
    notifyListeners();

    try {
      final data = await ApiService.getConversations(jwt);

      chats = data;
      loading = false;
      notifyListeners();
    } catch (_) {
      loading = false;
      notifyListeners();
    }
  }

  /// 🔥 REALTIME UPDATE
  void updateChatList(dynamic msg) {
    final senderId = msg['senderId']?.toString() ?? "";
    final receiverId = msg['receiverId']?.toString() ?? "";
    final text = (msg['text'] ?? "").toString();

    final otherUserId =
        senderId == myId ? receiverId : senderId;

    int index = chats.indexWhere(
      (c) => c['userId'].toString() == otherUserId,
    );

    if (index != -1) {
      chats[index]['lastMessage'] = text;
      chats[index]['createdAt'] =
          DateTime.now().toIso8601String();
      chats[index]['senderId'] = senderId;

      if (senderId != myId) {
        chats[index]['unreadCount'] =
            (chats[index]['unreadCount'] ?? 0) + 1;
      }
    } else {
      chats.insert(0, {
        'userId': otherUserId,
        'name': "Narada Link User",
        'username': "",
        'avatar': null,
        'lastMessage': text,
        'createdAt': DateTime.now().toIso8601String(),
        'senderId': senderId,
        'unreadCount': senderId == myId ? 0 : 1,
        'isOnline': false,
        'lastSeen': null,
      });
    }

    chats.sort((a, b) =>
        DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));

    notifyListeners();
  }

  /// 🕒 TIME FORMAT
  String formatChatTime(String? date) {
    if (date == null || date.isEmpty) return "";

    try {
      final dt = DateTime.parse(date).toLocal();
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final messageDay = DateTime(dt.year, dt.month, dt.day);

      final diff = today.difference(messageDay).inDays;

      if (diff == 0) {
        return DateFormat('h:mm a').format(dt);
      } else if (diff == 1) {
        return "Yesterday";
      } else {
        return DateFormat('d MMM').format(dt);
      }
    } catch (_) {
      return "";
    }
  }

  /// 🟢 STATUS TEXT
  String getStatusText(chat) {
    if (chat['isOnline'] == true) return "🟢 Online";

    if (chat['lastSeen'] == null) return "";

    try {
      final diff = DateTime.now()
          .difference(DateTime.parse(chat['lastSeen']));

      if (diff.inMinutes < 1) return "👀 just now";
      if (diff.inMinutes < 60)
        return "👀 ${diff.inMinutes}m ago";
      if (diff.inHours < 24)
        return "💤 ${diff.inHours}h ago";

      return "💤 ${diff.inDays}d ago";
    } catch (_) {
      return "";
    }
  }

  /// 🧹 DISPOSE
  void disposeController() {
    socket.disconnect();
  }
}