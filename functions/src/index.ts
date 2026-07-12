import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { cancelBookingLogic } from './bookings/cancelBooking';
import { cleanupUserDataLogic } from './users/cleanupUserData';

admin.initializeApp();
const db = admin.firestore();

// SECURITY: confirmBooking callable has been intentionally removed.
// Booking confirmation is only possible via the stripeWebhook endpoint,
// which verifies the Stripe payment_intent.succeeded event with signature validation.
// Any attempt to add a public confirmBooking callable is a security regression (Audit #1).

/**
 * Callable Cloud Function to cancel a pending or confirmed booking.
 */
export const cancelBooking = onCall({ enforceAppCheck: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const bookingId = request.data.bookingId;
  if (!bookingId) {
    throw new HttpsError('invalid-argument', 'The function must be called with a bookingId parameter.');
  }

  try {
    const result = await cancelBookingLogic(db, bookingId, request.auth.uid);
    return result;
  } catch (error: any) {
    throw new HttpsError('internal', error.message || 'Unknown error occurred during booking cancellation.');
  }
});

/**
 * Callable Cloud Function to delete user-related Firestore data.
 */
export const cleanupUserData = onCall({ enforceAppCheck: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  try {
    const result = await cleanupUserDataLogic(db, request.auth.uid);
    return result;
  } catch (error: any) {
    throw new HttpsError('internal', error.message || 'Unknown error occurred during user data cleanup.');
  }
});

export { onConciergeMessageCreated } from './concierge/onConciergeMessageCreated';
export { onReviewSubmitted } from './reviews/onReviewSubmitted';
export { sendPushOnNotificationCreated } from './notifications/sendPushOnNotificationCreated';
export { enforcePasswordPolicy } from './auth/enforcePasswordPolicy';
export { setAdminClaims } from './admin/setAdminClaims';
export { adminUpdateBookingStatus } from './admin/adminUpdateBookingStatus';
export { adminIssueRefund } from './admin/adminIssueRefund';
export { adminUpdateUser } from './admin/adminUpdateUser';
export { adminReplyToConciergeThread } from './admin/adminReplyToConciergeThread';
export { adminSendNotification } from './admin/adminSendNotification';
export { adminManageStaff } from './admin/adminManageStaff';
export { adminDeleteUser } from './admin/adminDeleteUser';
export { adminCreateUser } from './admin/adminCreateUser';

export { stripeWebhook } from './stripe/stripeWebhook';
