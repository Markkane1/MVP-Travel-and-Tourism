import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';

/**
 * Cloud Function triggered on any new message created in a concierge thread.
 *
 * Handles two distinct flows:
 *
 * 1. USER message → Show typing indicator then send Elena's auto-reply.
 *    (Simulates a quick acknowledgement while real staff reviews the thread.)
 *
 * 2. STAFF message → Write a Firestore notification doc for the customer so that
 *    sendPushOnNotificationCreated dispatches a real FCM push to their device.
 *    This is the key flow that was previously missing.
 */
export const onConciergeMessageCreated = onDocumentCreated(
  'concierge_threads/{userId}/messages/{messageId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const messageData = snapshot.data();
    const db = admin.firestore();
    const userId = event.params.userId;

    // ── Flow 1: User sent a message → auto-reply bot ─────────────────────────
    if (messageData.senderType === 'user') {
      try {
        // Set typing indicator
        await db.collection('concierge_threads').doc(userId).set(
          { isTyping: true },
          { merge: true }
        );

        // Simulate typing delay
        await new Promise((resolve) => setTimeout(resolve, 2200));

        // Look up assigned conciergeId from the user's profile
        const userDoc = await db.collection('users').doc(userId).get();
        let conciergeId = 'concierge-elena';
        if (userDoc.exists) {
          conciergeId = userDoc.data()?.conciergeId || 'concierge-elena';
        }

        // Post Elena's auto-reply
        await db.collection('concierge_threads').doc(userId).collection('messages').add({
          senderId: conciergeId,
          senderType: 'concierge',
          text: "Thanks for reaching out! I'll have a tailored option ready for you within 24 hours.",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Clear typing indicator
        await db.collection('concierge_threads').doc(userId).update({
          isTyping: false,
        });
      } catch (e) {
        console.error('Error simulating concierge auto-reply:', e);
      }
      return;
    }

    // ── Flow 2: Staff sent a message → notify the customer via FCM ───────────
    if (messageData.senderType === 'staff' || messageData.senderType === 'concierge') {
      try {
        // Write a notification doc — sendPushOnNotificationCreated will pick this
        // up and dispatch the FCM push to the customer's registered device.
        const notificationRef = db
          .collection('notifications')
          .doc(userId)
          .collection('items')
          .doc();

        await notificationRef.set({
          title: 'New message from your concierge',
          body: messageData.text?.substring(0, 100) || 'You have a new message from your travel concierge.',
          type: 'concierge',
          deepLink: '/concierge',
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`Concierge push notification queued for user ${userId}`);
      } catch (e) {
        console.error('Error writing concierge notification doc:', e);
      }
    }
  }
);
