import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';
import { assertActiveAdmin } from './authz';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'sk_test_mock', {
  apiVersion: '2023-10-16',
});

/**
 * Callable Cloud Function to issue a refund by an admin.
 *
 * SECURITY FIX #8: The Stripe refund API call has been moved OUTSIDE the
 * Firestore transaction. Firestore transactions may retry their callbacks,
 * which would cause the external refund call to execute multiple times and
 * issue duplicate refunds. The correct pattern is:
 *   1. Read + validate booking state (can be inside a transaction if needed)
 *   2. Call external Stripe API once, outside the transaction
 *   3. Update Firestore state after confirmation from Stripe
 *
 * SECURITY FIX #10: All audit log writes happen from the backend function,
 * not from client code.
 */
export const adminIssueRefundLogic = async (
  db: admin.firestore.Firestore,
  callerAuth: any,
  bookingId: string,
  reason: string
) => {
  await assertActiveAdmin(db, callerAuth);

  // 2. Read booking state outside the transaction
  const bookingRef = db.collection('bookings').doc(bookingId);
  const bookingDoc = await bookingRef.get();

  if (!bookingDoc.exists) {
    throw new HttpsError('not-found', 'Booking not found');
  }

  const bookingData = bookingDoc.data()!;

  if (bookingData.refunded) {
    throw new HttpsError('failed-precondition', 'Booking is already refunded');
  }

  // 3. Call Stripe OUTSIDE any Firestore transaction to avoid duplicate refunds on retries.
  if (bookingData.stripePaymentIntentId) {
    try {
      await stripe.refunds.create({
        payment_intent: bookingData.stripePaymentIntentId,
        reason: 'requested_by_customer',
        // Idempotency key tied to this specific booking refund attempt
        // ensures duplicate Stripe calls are safely de-duplicated on Stripe's side.
      }, {
        idempotencyKey: `refund-${bookingId}`,
      });
    } catch (stripeError: any) {
      throw new HttpsError('internal', `Stripe refund failed: ${stripeError.message}`);
    }
  } else {
    console.warn(`Booking ${bookingId} has no stripePaymentIntentId. Proceeding with logical refund.`);
  }

  // 4. Finalize state in Firestore as a transaction (no external calls inside)
  await db.runTransaction(async (transaction) => {
    // Re-read inside transaction for consistency
    const freshDoc = await transaction.get(bookingRef);
    if (freshDoc.data()?.refunded) {
      // Already marked refunded by a concurrent call — do nothing
      return;
    }

    transaction.update(bookingRef, {
      refunded: true,
      refundReason: reason,
      refundedAt: admin.firestore.FieldValue.serverTimestamp(),
      refundedBy: callerAuth.uid,
      status: 'cancelled',
      lastAdminActionAt: admin.firestore.FieldValue.serverTimestamp(),
      lastAdminActionBy: callerAuth.uid,
    });

    const notificationRef = db.collection('notifications').doc(bookingData.userId).collection('items').doc();
    transaction.set(notificationRef, {
      title: 'Booking Refunded',
      body: `Your booking has been refunded. Reason: ${reason}`,
      type: 'booking_refund',
      deepLink: `/trips/${bookingId}`,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  // 5. Write audit log from backend (SECURITY FIX #10: backend-only writes)
  await db.collection('admin_audit_logs').add({
    actorUid: callerAuth.uid,
    actorEmail: callerAuth.token.email || 'unknown',
    actorRole: callerAuth.token.role || 'admin',
    action: 'adminIssueRefund',
    targetType: 'booking',
    targetId: bookingId,
    summary: 'Issued refund for booking',
    before: { refunded: false, status: bookingData.status },
    after: { refunded: true, status: 'cancelled' },
    reason: reason,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, message: 'Refund issued successfully' };
};

export const adminIssueRefund = onCall({ enforceAppCheck: true }, async (request) => {
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
