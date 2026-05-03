// services/userService.js

import User from "../models/User.js";
import { validateUsername } from "../utils/validators.js";

/// 👤 GET USER BY ID
export const getUserById = async (userId) => {
  return await User.findById(userId);
};


/// 🧠 SET USERNAME + NAME LOGIC
export const updateUsernameAndName = async ({
  userId,
  name,
  username,
}) => {
  const user = await User.findById(userId);

  if (!user) {
    return { error: "User not found" };
  }

  /// 🔥 NAME UPDATE
  if (name && name.trim().length >= 2) {
    user.name = name.trim();
  }

  /// 🔥 USERNAME UPDATE
  if (username) {
    const clean = username.toLowerCase().trim();

    const error = validateUsername
      ? validateUsername(clean)
      : null;

    if (error) {
      return { error };
    }

    if (user.username) {
      return { error: "Username already set" };
    }

    const exists = await User.findOne({ username: clean });

    if (exists) {
      return { error: "Username already taken" };
    }

    user.username = clean;
  }

  await user.save();

  return { user };
};


/// ✏️ SET NAME ONLY
export const updateName = async (userId, name) => {
  if (!name || name.trim().length < 2) {
    return { error: "Valid name required" };
  }

  const user = await User.findByIdAndUpdate(
    userId,
    { name: name.trim() },
    { new: true }
  );

  if (!user) {
    return { error: "User not found" };
  }

  return { user };
};


/// 🧑‍💼 UPDATE PROFILE (NAME + AVATAR)
export const updateUserProfile = async ({
  userId,
  name,
  avatar,
}) => {
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

  if (!user) {
    return { error: "User not found" };
  }

  return { user };
};


/// 🔍 SEARCH USERS
export const searchUsersService = async (query, currentUserId) => {
  if (!query) return [];

  const users = await User.find({
    username: { $regex: query, $options: "i" },
    _id: { $ne: currentUserId },
  })
    .select("name username avatar isOnline lastSeen")
    .limit(20);

  return users.map((u) => ({
    _id: u._id,
    name:
      u.name && u.name.trim() !== ""
        ? u.name
        : "Narada Link User",
    username: u.username || "",
    avatar: u.avatar || null,
    isOnline: u.isOnline || false,
    lastSeen: u.lastSeen || null,
  }));
};


/// 👤 GET CURRENT USER DATA
export const getCurrentUser = async (userId) => {
  const user = await User.findById(userId);

  if (!user) {
    return { error: "User not found" };
  }

  return {
    ...user._doc,
    name: user.name || "Narada Link User",
  };
};


/// 🔔 SAVE FCM TOKEN
export const saveFcmTokenService = async (userId, token) => {
  if (!token) {
    return { error: "FCM token required" };
  }

  await User.findByIdAndUpdate(userId, {
    fcmToken: token,
  });

  return { success: true };
};


/// 🟢 GET USER STATUS
export const getUserStatusService = async (userId) => {
  const user = await User.findById(userId)
    .select("isOnline lastSeen");

  if (!user) {
    return { error: "User not found" };
  }

  return {
    isOnline: user.isOnline,
    lastSeen: user.lastSeen,
  };
};