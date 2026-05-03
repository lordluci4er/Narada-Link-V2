import admin from "../config/firebaseAdmin.js";

/// 🔔 SEND PUSH NOTIFICATION
export const sendPushNotification = async ({
  token,
  title,
  body,
}) => {
  try {
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: {
        title,
        body,
      },
    });

  } catch (err) {
    console.log("❌ FCM Error:", err.message);
  }
};