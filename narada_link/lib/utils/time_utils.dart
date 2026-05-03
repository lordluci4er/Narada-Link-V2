import 'package:intl/intl.dart';

/// 🕒 FORMAT CHAT TIME
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

/// 🟢 USER STATUS TEXT
String getStatusText(Map chat) {
  if (chat['isOnline'] == true) return "🟢 Online";

  if (chat['lastSeen'] == null) return "";

  try {
    final diff =
        DateTime.now().difference(DateTime.parse(chat['lastSeen']));

    if (diff.inMinutes < 1) return "👀 just now";
    if (diff.inMinutes < 60) return "👀 ${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "💤 ${diff.inHours}h ago";

    return "💤 ${diff.inDays}d ago";
  } catch (_) {
    return "";
  }
}