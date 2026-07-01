import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';

/**
 * Cloud Function triggered on any new message created in a concierge thread.
 * Simulates a typing indicator delay and publishes a canned response.
 */
export const onConciergeMessageCreated = onDocumentCreated(
  'concierge_threads/{userId}/messages/{messageId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const messageData = snapshot.data();
    // Only trigger auto-replies for messages sent by the user
    if (messageData.senderType !== 'user') return;

    const db = admin.firestore();
    const userId = event.params.userId;

    try {
      // 1. Set typing indicator to true on the thread root doc
      await db.collection('concierge_threads').doc(userId).set(
        {
          isTyping: true,
        },
        { merge: true }
      );

      // 2. Simulate Elena "typing" delay between 1.5 and 3 seconds
      await new Promise((resolve) => setTimeout(resolve, 2200));

      // 3. Look up assigned conciergeId from the user's profile
      const userDoc = await db.collection('users').doc(userId).get();
      let conciergeId = 'concierge-elena';
      if (userDoc.exists) {
        conciergeId = userDoc.data()?.conciergeId || 'concierge-elena';
      }

      // 4. Add Elena's auto-reply message
      await db.collection('concierge_threads').doc(userId).collection('messages').add({
        senderId: conciergeId,
        senderType: 'concierge',
        text: "Thanks for reaching out! I'll have a tailored option ready for you within 24 hours.",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 5. Unset typing indicator on the thread root doc
      await db.collection('concierge_threads').doc(userId).update({
        isTyping: false,
      });
    } catch (e) {
      console.error('Error simulating concierge typing indicator/auto-reply:', e);
    }
  }
);
