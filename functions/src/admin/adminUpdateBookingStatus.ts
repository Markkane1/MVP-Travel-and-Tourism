import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

/**
 * Callable Cloud Function to update booking status by an admin.
 */
export const adminUpdateBookingStatusLogic = async (
  db: admin.firestore.Firestore,
  callerAuth: any,
  bookingId: string,
  nextStatus: string,
  reason?: string
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
    const currentStatus = bookingData.status;

    // 2. Validate allowed transitions
    const allowedTransitions: Record<string, string[]> = {
      'pending': ['confirmed', 'cancelled'],
      'confirmed': ['completed', 'cancelled'],
      'completed': [],
      'cancelled': [],
    };

    const possibleNextStates = allowedTransitions[currentStatus] || [];
    if (!possibleNextStates.includes(nextStatus)) {
      throw new HttpsError('failed-precondition', `Cannot transition booking from ${currentStatus} to ${nextStatus}`);
    }

    // 3. Update booking
    transaction.update(bookingRef, {
      status: nextStatus,
      adminNotes: reason || admin.firestore.FieldValue.delete(),
      lastAdminActionAt: admin.firestore.FieldValue.serverTimestamp(),
      lastAdminActionBy: callerAuth.uid,
    });

    // 3.1 Points Handling
    if (currentStatus === 'pending' && nextStatus === 'confirmed') {
       // Award points
       const totalPrice = bookingData.totalPrice || 0;
       const pointsToAward = Math.floor(totalPrice / 10);
       
       const userRef = db.collection('users').doc(bookingData.userId);
       const userDoc = await transaction.get(userRef);
       let currentPoints = 0;
       if (userDoc.exists) {
         currentPoints = userDoc.data()?.loyaltyPoints || 0;
       }
       transaction.update(userRef, { loyaltyPoints: currentPoints + pointsToAward });
    } else if (currentStatus === 'confirmed' && nextStatus === 'cancelled') {
       // Claw back points
       const totalPrice = bookingData.totalPrice || 0;
       const pointsToDeduct = Math.floor(totalPrice / 10);
       
       const userRef = db.collection('users').doc(bookingData.userId);
       const userDoc = await transaction.get(userRef);
       let currentPoints = 0;
       if (userDoc.exists) {
         currentPoints = userDoc.data()?.loyaltyPoints || 0;
       }
       const newPoints = Math.max(0, currentPoints - pointsToDeduct);
       transaction.update(userRef, { loyaltyPoints: newPoints });
    }

    // 4. Optionally emit notification to user
    const notificationRef = db.collection('notifications').doc(bookingData.userId).collection('items').doc();
    transaction.set(notificationRef, {
      title: `Booking ${nextStatus.charAt(0).toUpperCase() + nextStatus.slice(1)}`,
      body: `Your booking status is now ${nextStatus}.`,
      type: 'booking_status',
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
      action: 'adminUpdateBookingStatus',
      targetType: 'booking',
      targetId: bookingId,
      summary: `Updated booking from ${currentStatus} to ${nextStatus}`,
      before: { status: currentStatus },
      after: { status: nextStatus },
      reason: reason || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, status: nextStatus };
  });
};

export const adminUpdateBookingStatus = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be logged in.');
  }

  const { bookingId, nextStatus, reason } = request.data;
  if (!bookingId || typeof bookingId !== 'string') {
    throw new HttpsError('invalid-argument', 'A valid bookingId must be provided.');
  }
  if (!nextStatus || typeof nextStatus !== 'string') {
    throw new HttpsError('invalid-argument', 'A valid nextStatus must be provided.');
  }

  return await adminUpdateBookingStatusLogic(admin.firestore(), request.auth, bookingId, nextStatus, reason);
});
