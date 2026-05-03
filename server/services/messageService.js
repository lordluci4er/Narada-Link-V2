// services/messageService.js
import mongoose from "mongoose";
import Message from "../models/Message.js";
import User from "../models/User.js";

/// 🧱 CREATE MESSAGE
export const createMessage = async ({ senderId, receiverId, text }) => {
  const msg = await Message.create({
    senderId: senderId.toString(),
    receiverId: receiverId.toString(),
    text,
    seen: false,
    status: "sent",
    deliveredAt: null,
    seenAt: null,
  });
  return msg;
};

/// 📥 GET CHAT MESSAGES
export const getChatMessages = async ({ myId, userId }) => {
  const messages = await Message.find({
    $or: [
      { senderId: myId, receiverId: userId },
      { senderId: userId, receiverId: myId },
    ],
  }).sort({ createdAt: 1 });

  return messages.map((m) => ({
    ...m.toObject(),
    senderId: m.senderId.toString(),
    receiverId: m.receiverId.toString(),
    text: m.text || "",
    status: m.status || "sent",
    deliveredAt: m.deliveredAt || null,
    seenAt: m.seenAt || null,
  }));
};

/// 👀 MARK AS SEEN (RETURN IDS)
export const markSeen = async ({ senderId, receiverId }) => {
  const messages = await Message.find({
    senderId: senderId.toString(),
    receiverId: receiverId.toString(),
    status: { $ne: "seen" },
  });

  if (!messages.length) return { ids: [], seenAt: null };

  const ids = messages.map((m) => m._id);
  const seenAt = new Date();

  await Message.updateMany(
    { _id: { $in: ids } },
    {
      $set: {
        status: "seen",
        seen: true,
        seenAt,
      },
    }
  );

  return { ids, seenAt };
};

/// 📦 MARK AS DELIVERED (RETURN IDS + senders)
export const markDelivered = async ({ receiverId }) => {
  const messages = await Message.find({
    receiverId: receiverId.toString(),
    status: "sent",
  });

  if (!messages.length) return { updates: [] };

  const ids = messages.map((m) => m._id);
  const deliveredAt = new Date();

  await Message.updateMany(
    { _id: { $in: ids } },
    {
      $set: {
        status: "delivered",
        deliveredAt,
      },
    }
  );

  // sender-wise emit ke liye pairing
  const updates = messages.map((m) => ({
    messageId: m._id,
    senderId: m.senderId.toString(),
  }));

  return { updates, deliveredAt };
};

/// 🏠 GET CONVERSATIONS (WITH UNREAD)
export const getUserConversations = async ({ myId }) => {
  const conversations = await Message.aggregate([
    {
      $match: {
        $or: [{ senderId: myId }, { receiverId: myId }],
      },
    },
    { $sort: { createdAt: -1 } },
    {
      $group: {
        _id: {
          $cond: [
            { $eq: ["$senderId", myId] },
            "$receiverId",
            "$senderId",
          ],
        },
        lastMessage: { $first: "$text" },
        createdAt: { $first: "$createdAt" },
        unreadCount: {
          $sum: {
            $cond: [
              {
                $and: [
                  { $eq: ["$receiverId", myId] },
                  { $ne: ["$status", "seen"] },
                ],
              },
              1,
              0,
            ],
          },
        },
      },
    },
  ]);

  const userIds = conversations.map(
    (c) => new mongoose.Types.ObjectId(c._id)
  );

  const users = await User.find({
    _id: { $in: userIds },
  }).select("name username avatar");

  const result = conversations.map((c) => {
    const user = users.find(
      (u) => u._id.toString() === c._id.toString()
    );

    return {
      userId: c._id.toString(),
      name: user?.name?.trim() || "Narada Link User",
      username: user?.username || "",
      avatar: user?.avatar || null,
      lastMessage: c.lastMessage || "",
      createdAt: c.createdAt,
      unreadCount: c.unreadCount || 0,
    };
  });

  return result.sort(
    (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
  );
};

/// 🕘 GET RECENT CHATS
export const getRecentChatsService = async ({ userId }) => {
  const chats = await Message.aggregate([
    {
      $match: {
        $or: [{ senderId: userId }, { receiverId: userId }],
      },
    },
    { $sort: { createdAt: -1 } },
    {
      $group: {
        _id: {
          $cond: [
            { $eq: ["$senderId", userId] },
            "$receiverId",
            "$senderId",
          ],
        },
        lastMessage: { $first: "$text" },
        createdAt: { $first: "$createdAt" },
      },
    },
    { $sort: { createdAt: -1 } },
  ]);

  return chats;
};