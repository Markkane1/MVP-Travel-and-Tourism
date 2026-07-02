import * as admin from 'firebase-admin';

/**
 * Reusable core transaction logic to cancel a booking.
 * 
 * Verifies document ownership and status, transactionally cancels it,
 * and writes a cancellation notification document.
 */
export async function cancelBookingLogic(
  db: admin.firestore.Firestore,
  bookingId: string,
  userId: string
): Promise<{ success: boolean }> {
  const bookingRef = db.collection('bookings').doc(bookingId);

  return db.runTransaction(async (transaction) => {
    // 1. Get the booking doc
    const bookingDoc = await transaction.get(bookingRef);
    if (!bookingDoc.exists) {
      throw new Error('Booking not found');
    }
    const bookingData = bookingDoc.data();
    if (!bookingData) {
      throw new Error('Booking data is empty');
    }

    // Verify ownership
    if (bookingData.userId !== userId) {
      throw new Error('Unauthorized booking ownership');
    }
    
    // Verify status is not already completed or cancelled
    if (bookingData.status === 'cancelled') {
      throw new Error('Booking is already cancelled');
    }
    if (bookingData.status === 'completed') {
      throw new Error('Completed bookings cannot be cancelled');
    }

    // 2. Update booking status to 'cancelled'
    transaction.update(bookingRef, {
      status: 'cancelled',
    });

    // TODO: trigger refund once real payment integration exists
    // Per rules: do not reference stripePaymentIntentId or any payment-provider refund API in mock.

    // 3. Write a notifications/{uid}/items document
    const notificationRef = db.collection('notifications').doc(userId).collection('items').doc();
    transaction.set(notificationRef, {
      title: 'Booking Cancelled',
      body: `Your booking for ${bookingData.tourSnapshot?.title || 'your destination'} has been cancelled.`,
      type: 'booking',
      deepLink: `/trips/${bookingId}`,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  });
}
