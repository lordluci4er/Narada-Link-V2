// socket/user.socket.js

import User from "../models/User.js";
import { validateUsername } from "../utils/validators.js";

export default function userSocket(io, socket) {

  /// =========================
  /// 👤 UPDATE PROFILE (NAME / AVATAR)
  /// =========================
  socket.on("updateProfile", async (data) => {
    try {
      const { userId, name, avatar } = data;

      if (!userId) return;

      const updateData = {};

      if (name && name.trim().length >= 2) {
        updateData.name = name.trim();
      }

      if (avatar && avatar.trim().length > 0) {
        updateData.avatar = avatar.trim();
      }

      const user = await User.findByIdAndUpdate(
        userId,
        updateData,
        { new: true }
      );

      if (!user) return;

      /// 🔥 BROADCAST UPDATE
      io.emit("userUpdated", {
        userId: user._id.toString(),
        name: user.name || "Narada Link User",
        avatar: user.avatar || null,
      });

    } catch (err) {
      console.log("❌ updateProfile socket error:", err.message);
    }
  });

  /// =========================
  /// 🧠 SET USERNAME + NAME
  /// =========================
  socket.on("setUsername", async (data, callback) => {
    try {
      const { userId, name, username } = data;

      const user = await User.findById(userId);
      if (!user) {
        return callback?.({ error: "User not found" });
      }

      /// NAME
      if (name && name.trim().length >= 2) {
        user.name = name.trim();
      }

      /// USERNAME
      if (username) {
        const clean = username.toLowerCase().trim();

        const error = validateUsername
          ? validateUsername(clean)
          : null;

        if (error) {
          return callback?.({ error });
        }

        if (user.username) {
          return callback?.({ error: "Username already set" });
        }

        const exists = await User.findOne({ username: clean });

        if (exists) {
          return callback?.({ error: "Username already taken" });
        }

        user.username = clean;
      }

      await user.save();

      /// 🔥 BROADCAST
      io.emit("userUpdated", {
        userId: user._id.toString(),
        name: user.name || "Narada Link User",
        avatar: user.avatar || null,
      });

      callback?.({
        success: true,
        user: {
          ...user._doc,
          name: user.name || "Narada Link User",
        },
      });

    } catch (err) {
      console.log("❌ setUsername socket error:", err.message);
      callback?.({ error: "Server error" });
    }
  });

}