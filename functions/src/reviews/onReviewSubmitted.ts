import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';

/**
 * Cloud Function triggered on new tour reviews.
 * Increments the user's loyaltyPoints by 250 and updates booking status to reviewed: true.
 */
export const onReviewSubmitted = onDocumentCreated(
  'tours/{tourId}/reviews/{reviewId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const data = snapshot.data();
    const db = admin.firestore();
    const userId = data.userId;
    const bookingId = data.bookingId;

    if (!userId || !bookingId) return;

    try {
      // 1. Transactionally increment loyaltyPoints by 250 on the user doc
      const userRef = db.collection('users').doc(userId);
      await db.runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userRef);
        let points = 0;
        if (userDoc.exists) {
          points = userDoc.data()?.loyaltyPoints || 0;
        }
        transaction.update(userRef, { loyaltyPoints: points + 250 });
      });

      // 2. Update the booking document to set reviewed: true
      await db.collection('bookings').doc(bookingId).update({
        reviewed: true,
      });
    } catch (e) {
      console.error('Error in onReviewSubmitted Cloud Function trigger:', e);
    }
  }
);
