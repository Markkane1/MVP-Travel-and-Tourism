import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';

/**
 * Cloud Function triggered on every new notification item written to Firestore.
 * Centralizes push notification delivery via FCM using user-specific fcmTokens.
 */
export const sendPushOnNotificationCreated = onDocumentCreated(
  'notifications/{userId}/items/{notificationId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const notification = snapshot.data();
    const userId = event.params.userId;
    const db = admin.firestore();

    try {
      // 1. Retrieve the target user's fcmToken from their profile
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        console.log(`User ${userId} doc does not exist.`);
        return;
      }

      const fcmToken = userDoc.data()?.fcmToken;
      if (!fcmToken) {
        console.log(`No fcmToken saved on profile for user ${userId}. Skipping push payload.`);
        return;
      }

      // 2. Format messaging message object
      const message: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title: notification.title || 'MVP Travel Alert',
          body: notification.body || '',
        },
        data: {
          type: notification.type || 'system',
          deepLink: notification.deepLink || '',
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      // 3. Dispatch the payload through admin messaging
      const response = await admin.messaging().send(message);
      console.log(`Successfully dispatched push notification to user ${userId}. Message ID: ${response}`);
    } catch (e) {
      console.error(`Error sending push notification to user ${userId}:`, e);
    }
  }
);
