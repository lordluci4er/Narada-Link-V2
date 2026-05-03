import {
  updateUsernameAndName,
  updateName,
  updateUserProfile,
  searchUsersService,
  getCurrentUser,
  saveFcmTokenService,
  getUserStatusService,
} from "../services/userService.js";


/// 🔥 SET USERNAME + NAME
export const setUsername = async (req, res) => {
  try {
    const userId = req.user?.id || req.user;
    const { name, username } = req.body;

    const result = await updateUsernameAndName({
      userId,
      name,
      username,
    });

    if (result.error) {
      return res.status(400).json({ msg: result.error });
    }

    const user = result.user;

    res.json({
      msg: "Updated",
      user: {
        ...user._doc,
        name: user.name || "Narada Link User",
      },
    });

  } catch (err) {
    console.error("Set Username Error:", err);
    res.status(500).json({ msg: "Server error" });
  }
};


/// 🔥 SET NAME
export const setName = async (req, res) => {
  try {
    const userId = req.user?.id || req.user;
    const { name } = req.body;

    const result = await updateName(userId, name);

    if (result.error) {
      return res.status(400).json({ msg: result.error });
    }

    const user = result.user;

    res.json({
      ...user._doc,
      name: user.name || "Narada Link User",
    });

  } catch (err) {
    console.error("Set Name Error:", err);
    res.status(500).json({ msg: "Error setting name" });
  }
};


/// 🔥 UPDATE PROFILE
export const updateProfile = async (req, res) => {
  try {
    const userId = req.user?.id || req.user;
    const { name, avatar } = req.body;

    const result = await updateUserProfile({
      userId,
      name,
      avatar,
    });

    if (result.error) {
      return res.status(400).json({ msg: result.error });
    }

    const user = result.user;

    res.json({
      ...user._doc,
      name: user.name || "Narada Link User",
    });

  } catch (err) {
    console.error("Update Profile Error:", err);
    res.status(500).json({ msg: "Profile update failed" });
  }
};


/// 🔍 SEARCH USERS
export const searchUsers = async (req, res) => {
  try {
    const query = (req.query.username || "").toLowerCase().trim();
    const userId = req.user?.id || req.user;

    const users = await searchUsersService(query, userId);

    res.json(users);

  } catch (err) {
    console.error("Search Error:", err);
    res.status(500).json({ msg: "Server error" });
  }
};


/// 👤 GET CURRENT USER
export const getMe = async (req, res) => {
  try {
    const userId = req.user?.id || req.user;

    const result = await getCurrentUser(userId);

    if (result.error) {
      return res.status(404).json({ msg: result.error });
    }

    res.json(result);

  } catch (error) {
    console.log("❌ getMe error:", error.message);
    res.status(500).json({ msg: "Server error" });
  }
};


/// 🔔 SAVE FCM TOKEN
export const saveFcmToken = async (req, res) => {
  try {
    const userId = req.user?.id || req.user;
    const { token } = req.body;

    const result = await saveFcmTokenService(userId, token);

    if (result.error) {
      return res.status(400).json({ msg: result.error });
    }

    res.json({ msg: "Token saved" });

  } catch (err) {
    console.error("FCM Save Error:", err);
    res.status(500).json({ msg: "Error saving token" });
  }
};


/// 🟢 GET USER STATUS
export const getUserStatus = async (req, res) => {
  try {
    const result = await getUserStatusService(req.params.userId);

    if (result.error) {
      return res.status(404).json({ msg: result.error });
    }

    res.json(result);

  } catch (err) {
    console.error("User Status Error:", err);
    res.status(500).json({ msg: "Server error" });
  }
};