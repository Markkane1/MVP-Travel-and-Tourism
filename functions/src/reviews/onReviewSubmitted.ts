import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';

/**
 * Cloud Function triggered on new tour reviews.
 * Increments the user's loyaltyPoints by 250 and updates booking status to reviewed: true.
 *
 * SECURITY FIX #2: Before awarding points the trigger now verifies:
 *   1. The booking exists and belongs to the same userId as the review
 *   2. The booking is in 'completed' status (not just any status)
 *   3. The booking has not already been marked as reviewed (idempotency)
 *   4. The booking's tourId matches the tour this review was submitted for
 *
 * This prevents a signed-in user from submitting a review on someone else's
 * booking or an incomplete booking to fraudulently earn loyalty points.
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
    const tourId = event.params.tourId;

    if (!userId || !bookingId) {
      console.warn('Review missing userId or bookingId, skipping points award.');
      return;
    }

    try {
      const bookingRef = db.collection('bookings').doc(bookingId);

      await db.runTransaction(async (transaction) => {
        const bookingDoc = await transaction.get(bookingRef);
        if (!bookingDoc.exists) {
          console.warn(`Booking ${bookingId} not found for review. No points awarded.`);
          return;
        }

        const bookingData = bookingDoc.data()!;

        // SECURITY FIX #2a: Booking must belong to the reviewer
        if (bookingData.userId !== userId) {
          console.error(`Review userId ${userId} does not match booking.userId ${bookingData.userId}. Skipping.`);
          return;
        }

        // SECURITY FIX #2b: Booking must be completed (not just any status)
        if (bookingData.status !== 'completed') {
          console.warn(`Booking ${bookingId} is not completed (status: ${bookingData.status}). No points awarded.`);
          return;
        }

        // SECURITY FIX #2c: Booking must match this tour
        if (bookingData.tourId !== tourId) {
          console.error(`Review tourId ${tourId} does not match booking.tourId ${bookingData.tourId}. Skipping.`);
          return;
        }

        // Idempotency: already reviewed
        if (bookingData.reviewed === true) {
          return;
        }

        // 1. Increment loyaltyPoints by 250 on the user doc
        const userRef = db.collection('users').doc(userId);
        const userDoc = await transaction.get(userRef);
        let points = 0;
        if (userDoc.exists) {
          points = userDoc.data()?.loyaltyPoints || 0;
        }
        transaction.update(userRef, { loyaltyPoints: points + 250 });

        // 2. Mark the booking as reviewed to prevent double-awarding
        transaction.update(bookingRef, { reviewed: true });
      });
    } catch (e) {
      console.error('Error in onReviewSubmitted Cloud Function trigger:', e);
    }
  }
);
