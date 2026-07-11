import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'sk_test_mock', {
  apiVersion: '2023-10-16',
});

/**
 * Callable Cloud Function to issue a refund by an admin.
 */
export const adminIssueRefundLogic = async (
  db: admin.firestore.Firestore,
  callerAuth: any,
  bookingId: string,
  reason: string
) => {
  // 1. Verify caller is authorized
  if (callerAuth?.token?.admin !== true) {
    throw new HttpsError(
      'permission-denied',
      'You must be an admin to perform this action.'
    );
  }

  return db.runTransaction(async (transaction) => {
    const bookingRef = db.collection('bookings').doc(bookingId);
    const bookingDoc = await transaction.get(bookingRef);

    if (!bookingDoc.exists) {
      throw new HttpsError('not-found', 'Booking not found');
    }

    const bookingData = bookingDoc.data()!;

    // 2. Validate refund eligibility
    if (bookingData.refunded) {
      throw new HttpsError('failed-precondition', 'Booking is already refunded');
    }

    if (!bookingData.stripePaymentIntentId) {
      // If there's no payment intent, we can still process a logical refund (e.g., if it was manual or mocked)
      console.warn(`Booking ${bookingId} has no stripePaymentIntentId. Proceeding with logical refund.`);
    } else {
      try {
        await stripe.refunds.create({
          payment_intent: bookingData.stripePaymentIntentId,
          reason: 'requested_by_customer',
        });
      } catch (stripeError: any) {
        throw new HttpsError('internal', `Stripe refund failed: ${stripeError.message}`);
      }
    }

    // 3. Update booking
    transaction.update(bookingRef, {
      refunded: true,
      refundReason: reason,
      refundedAt: admin.firestore.FieldValue.serverTimestamp(),
      refundedBy: callerAuth.uid,
      status: 'cancelled', // Usually a refund implies cancellation, or we can keep it as is. We'll set to cancelled.
      lastAdminActionAt: admin.firestore.FieldValue.serverTimestamp(),
      lastAdminActionBy: callerAuth.uid,
    });

    // 4. Optionally emit notification to user
    const notificationRef = db.collection('notifications').doc(bookingData.userId).collection('items').doc();
    transaction.set(notificationRef, {
      title: `Booking Refunded`,
      body: `Your booking has been refunded. Reason: ${reason}`,
      type: 'booking_refund',
      deepLink: `/trips/${bookingId}`,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 5. Write audit log
    const auditRef = db.collection('admin_audit_logs').doc();
    transaction.set(auditRef, {
      actorUid: callerAuth.uid,
      actorEmail: callerAuth.token.email || 'unknown',
      actorRole: callerAuth.token.role || 'admin',
      action: 'adminIssueRefund',
      targetType: 'booking',
      targetId: bookingId,
      summary: `Issued refund for booking`,
      before: { refunded: false, status: bookingData.status },
      after: { refunded: true, status: 'cancelled' },
      reason: reason,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, message: 'Refund issued successfully' };
  });
};

export const adminIssueRefund = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be logged in.');
  }

  const { bookingId, reason } = request.data;
  if (!bookingId || typeof bookingId !== 'string') {
    throw new HttpsError('invalid-argument', 'A valid bookingId must be provided.');
  }
  if (!reason || typeof reason !== 'string') {
    throw new HttpsError('invalid-argument', 'A valid reason must be provided.');
  }

  return await adminIssueRefundLogic(admin.firestore(), request.auth, bookingId, reason);
});
