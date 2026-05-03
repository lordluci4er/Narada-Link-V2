import {
  createMessage,
  getChatMessages,
  markSeen,
  markDelivered,
  getUserConversations,
  getRecentChatsService,
} from "../services/messageService.js";

import User from "../models/User.js";
import { sendPushNotification } from "../services/notificationService.js";

/// 🔥 SEND MESSAGE (API ONLY + PUSH)
export const sendMessage = async (req, res) => {
  try {
    const senderId = (req.user?.id || req.user).toString();
    const { receiverId, text } = req.body;

    if (!receiverId || !text) {
      return res.status(400).json({ msg: "Missing fields" });
    }

    /// 🧱 DB SAVE
    const message = await createMessage({
      senderId,
      receiverId,
      text,
    });

    /// 🔔 PUSH NOTIFICATION
    const sender = await User.findById(senderId);
    const receiver = await User.findById(receiverId);

    if (receiver?.fcmToken) {
      await sendPushNotification({
        token: receiver.fcmToken,
        title: sender?.name || "New Message",
        body: text,
      });
    }

    /// ❌ NO SOCKET HERE

    res.status(201).json(message);

  } catch (error) {
    console.error("Send Message Error:", error);
    res.status(500).json({ msg: "Server error" });
  }
};


/// 📥 GET MESSAGES (ONLY FETCH)
export const getMessages = async (req, res) => {
  try {
    const myId = (req.user?.id || req.user).toString();
    const userId = req.params.userId.toString();

    const messages = await getChatMessages({
      myId,
      userId,
    });

    /// ❌ NO AUTO SEEN HERE (socket karega)

    res.json(messages);

  } catch (error) {
    console.error("Get Messages Error:", error);
    res.status(500).json({ msg: "Server error" });
  }
};


/// 📦 MARK AS DELIVERED (API FALLBACK ONLY)
export const markAsDelivered = async (req, res) => {
  try {
    const myId = (req.user?.id || req.user).toString();

    const { updates } = await markDelivered({
      receiverId: myId,
    });

    res.json({
      msg: "Delivered updated",
      count: updates.length,
    });

  } catch (err) {
    console.error("Delivered Error:", err);
    res.status(500).json({ msg: "Error updating delivered" });
  }
};


/// 👀 MARK AS SEEN (API FALLBACK ONLY)
export const markAsSeen = async (req, res) => {
  try {
    const myId = (req.user?.id || req.user).toString();
    const userId = req.params.userId.toString();

    const { ids } = await markSeen({
      senderId: userId,
      receiverId: myId,
    });

    res.json({
      msg: "Seen updated",
      count: ids.length,
    });

  } catch (err) {
    console.error("Seen Error:", err);
    res.status(500).json({ msg: "Error updating seen" });
  }
};


/// 🏠 GET CONVERSATIONS
export const getConversations = async (req, res) => {
  try {
    const myId = (req.user?.id || req.user).toString();

    const data = await getUserConversations({ myId });

    res.json(data);

  } catch (err) {
    console.error("Conversations Error:", err);
    res.status(500).json({ msg: "Server error" });
  }
};


/// 🕘 GET RECENT CHATS
export const getRecentChats = async (req, res) => {
  try {
    const userId = (req.user?.id || req.user).toString();

    const data = await getRecentChatsService({ userId });

    res.json(data);

  } catch (err) {
    console.error("Recent Chats Error:", err);
    res.status(500).json({ msg: "Server error" });
  }
};