// socket/message.socket.js

import Message from "../models/Message.js";
import User from "../models/User.js";

export default function messageSocket(io, socket) {

  /// =========================
  /// 📤 SEND MESSAGE
  /// =========================
  socket.on("send_message", async (data) => {
    try {
      const { senderId, receiverId, text } = data;

      if (!senderId || !receiverId || !text) return;

      const message = await Message.create({
        senderId: senderId.toString(),
        receiverId: receiverId.toString(),
        text,
        status: "sent",
        seen: false,
        deliveredAt: null,
        seenAt: null,
      });

      const sender = await User.findById(senderId);

      /// 🔥 EMIT TO RECEIVER
      io.to(receiverId.toString()).emit("newMessage", {
        messageId: message._id,
        senderId,
        receiverId,
        text,
        createdAt: message.createdAt,
        senderName: sender?.name || "Narada Link User",
        status: "sent",
      });

    } catch (err) {
      console.log("❌ send_message error:", err.message);
    }
  });

  /// =========================
  /// 📦 DELIVERED
  /// =========================
  socket.on("messageDelivered", async () => {
    try {
      const myId = socket.userId;

      if (!myId) return;

      const messages = await Message.find({
        receiverId: myId,
        status: "sent",
      });

      if (!messages.length) return;

      const ids = messages.map((m) => m._id);

      await Message.updateMany(
        { _id: { $in: ids } },
        {
          $set: {
            status: "delivered",
            deliveredAt: new Date(),
          },
        }
      );

      /// 🔥 EMIT TO SENDERS
      messages.forEach((msg) => {
        io.to(msg.senderId.toString()).emit("messageDelivered", {
          messageId: msg._id,
        });
      });

    } catch (err) {
      console.log("❌ delivered error:", err.message);
    }
  });

  /// =========================
  /// 👀 SEEN
  /// =========================
  socket.on("messageSeen", async ({ userId }) => {
    try {
      const myId = socket.userId;

      if (!myId || !userId) return;

      const messages = await Message.find({
        senderId: userId,
        receiverId: myId,
        status: { $ne: "seen" },
      });

      if (!messages.length) return;

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

      /// 🔥 EMIT BACK TO SENDER
      io.to(userId.toString()).emit("messagesSeen", {
        messageIds: ids,
        seenAt,
      });

    } catch (err) {
      console.log("❌ seen error:", err.message);
    }
  });

}