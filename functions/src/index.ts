import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { confirmBookingLogic } from './bookings/confirmBooking';

admin.initializeApp();
const db = admin.firestore();

/**
 * Callable Cloud Function to confirm a pending booking.
 * Can be triggered directly by the client app checkout.
 */
export const confirmBooking = onCall(async (request) => {
  // Check authorization
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const bookingId = request.data.bookingId;
  if (!bookingId) {
    throw new HttpsError('invalid-argument', 'The function must be called with a bookingId parameter.');
  }

  try {
    const result = await confirmBookingLogic(db, bookingId, request.auth.uid);
    return result;
  } catch (error: any) {
    throw new HttpsError('internal', error.message || 'Unknown error occurred during booking confirmation.');
  }
});
