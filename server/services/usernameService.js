// services/usernameService.js

import User from "../models/User.js";
import { validateUsername } from "../utils/validators.js";

/// 🔤 CLEAN USERNAME
export const cleanUsername = (username) => {
  return username?.toLowerCase().trim();
};


/// ✅ VALIDATE USERNAME FORMAT
export const validateUsernameFormat = (username) => {
  if (!username) return "Username required";

  const clean = cleanUsername(username);

  const error = validateUsername ? validateUsername(clean) : null;

  if (error) return error;

  return null;
};


/// 🔍 CHECK USERNAME AVAILABLE
export const isUsernameAvailable = async (username) => {
  const clean = cleanUsername(username);

  const exists = await User.findOne({ username: clean });

  return !exists;
};


/// 🔒 SET USERNAME LOGIC (CORE)
export const setUsernameLogic = async ({ user, username }) => {
  if (!username) return { success: true };

  const clean = cleanUsername(username);

  /// validate
  const error = validateUsernameFormat(clean);
  if (error) {
    return { success: false, error };
  }

  /// already set
  if (user.username) {
    return {
      success: false,
      error: "Username already set",
    };
  }

  /// check availability
  const available = await isUsernameAvailable(clean);
  if (!available) {
    return {
      success: false,
      error: "Username already taken",
    };
  }

  /// set
  user.username = clean;

  return { success: true };
};