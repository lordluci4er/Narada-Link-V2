import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/chat_socket_service.dart';

class ChatController extends ChangeNotifier {
  final String jwt;
  final String userId;
  final String myId;

  ChatController({
    required this.jwt,
    required this.userId,
    required this.myId,
  });

  /// 🔌 SOCKET
  final SocketService socket = SocketService();
  late final ChatSocketService chatSocket;

  /// 🎯 CONTROLLERS
  final scrollController = ScrollController();
  final textController = TextEditingController();

  /// 📦 STATE
  List<Map<String, dynamic>> messages = [];
  bool loading = false;

  bool isOnline = false;
  String? lastSeen;

  Map<String, dynamic>? replyingTo;

  /// 🚀 INIT
  void init() {
    chatSocket = ChatSocketService(socket);

    loadMessages();
    loadUserStatus();

    /// 🔌 CONNECT
    chatSocket.init(myId);

    /// 👀 MARK SEEN ON OPEN
    chatSocket.sendSeen(userId);

    _initSocketListeners();
  }

  /// 🎧 SOCKET EVENTS
  void _initSocketListeners() {
    /// 📩 NEW MESSAGE
    chatSocket.onNewMessage(
      myId: myId,
      chatUserId: userId,
      onMessage: (msg) {
        messages.add(msg);

        notifyListeners();
        scrollToBottom();

        /// 👀 AUTO SEEN
        chatSocket.sendSeen(userId);
      },
    );

    /// 👀 SEEN
    chatSocket.onMessagesSeen(
      onSeen: (ids, seenAt) {
        for (var msg in messages) {
          if (ids.contains(msg['_id'])) {
            msg['status'] = "seen";
            msg['seenAt'] = seenAt;
          }
        }

        notifyListeners();
      },
    );

    /// 📦 DELIVERED
    chatSocket.onDelivered(
      onDelivered: (messageId) {
        final index =
            messages.indexWhere((m) => m['_id'] == messageId);

        if (index != -1) {
          messages[index]['status'] = "delivered";
          notifyListeners();
        }
      },
    );

    /// 🟢 USER STATUS
    chatSocket.onUserStatus(
      chatUserId: userId,
      onStatus: (online, seen) {
        isOnline = online;
        lastSeen = seen;
        notifyListeners();
      },
    );
  }

  /// 🔁 LOAD MESSAGES
  Future<void> loadMessages() async {
    loading = true;
    notifyListeners();

    try {
      final data = await ApiService.getMessages(userId, jwt);

      messages = List<Map<String, dynamic>>.from(data);
      loading = false;

      notifyListeners();
      scrollToBottom();
    } catch (_) {
      loading = false;
      notifyListeners();
    }
  }

  /// 🟢 LOAD STATUS
  Future<void> loadUserStatus() async {
    final data = await ApiService.getUserStatus(userId, jwt);

    if (data != null) {
      isOnline = data['isOnline'] ?? false;
      lastSeen = data['lastSeen'];
      notifyListeners();
    }
  }

  /// ✉️ SEND MESSAGE
  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    textController.clear();

    final tempId =
        DateTime.now().millisecondsSinceEpoch.toString();

    final newMsg = {
      "_id": tempId,
      "senderId": myId,
      "receiverId": userId,
      "text": text,
      "createdAt": DateTime.now().toIso8601String(),
      "status": "sent",
      "seenAt": null,
      "replyTo": replyingTo?['_id'],
      "replyText": replyingTo?['text'],
      "replySenderId": replyingTo?['senderId'],
    };

    messages.add(newMsg);
    notifyListeners();
    scrollToBottom();

    await ApiService.sendMessage(userId, text, jwt);

    clearReply();
  }

  /// 🔁 SCROLL
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 💬 REPLY
  void setReply(Map<String, dynamic> msg) {
    replyingTo = msg;
    notifyListeners();
  }

  void clearReply() {
    replyingTo = null;
    notifyListeners();
  }

  /// 🧹 DISPOSE
  void disposeController() {
    chatSocket.dispose(); // 🔥 important
    scrollController.dispose();
    textController.dispose();
  }
}