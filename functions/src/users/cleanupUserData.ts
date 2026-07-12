import * as admin from 'firebase-admin';

/**
 * Cleanup transaction/batch deletes all user related Firestore documents
 * including subcollections for savedTours, paymentMethods, and notifications.
 *
 * SECURITY FIX #12: This function now deletes ALL user-linked data including:
 *   - bookings where userId == uid (anonymized to preserve business records)
 *   - tour reviews authored by the user
 *   - Firebase Storage objects under users/{uid}/** and concierge attachments
 *
 * The auth user is only deleted AFTER cleanup succeeds to ensure orphaned PII
 * is not left behind if cleanup fails partway through.
 */
export async function cleanupUserDataLogic(
  db: admin.firestore.Firestore,
  userId: string
): Promise<{ success: boolean }> {
  const bucket = admin.storage().bucket();
  const batch = db.batch();

  // 1. Delete notifications items subcollection
  const notificationsItemsRef = db.collection('notifications').doc(userId).collection('items');
  const notificationDocs = await notificationsItemsRef.get();
  notificationDocs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  batch.delete(db.collection('notifications').doc(userId));

  // 2. Delete savedTours subcollection
  const savedToursRef = db.collection('users').doc(userId).collection('savedTours');
  const savedTourDocs = await savedToursRef.get();
  savedTourDocs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // 3. Delete paymentMethods subcollection
  const paymentMethodsRef = db.collection('users').doc(userId).collection('paymentMethods');
  const paymentMethodDocs = await paymentMethodsRef.get();
  paymentMethodDocs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // 4. Delete concierge thread and its messages
  const conciergeMessagesRef = db.collection('concierge_threads').doc(userId).collection('messages');
  const conciergeMessageDocs = await conciergeMessagesRef.get();
  conciergeMessageDocs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  batch.delete(db.collection('concierge_threads').doc(userId));

  // 5. SECURITY FIX #12: Anonymize user-linked bookings.
  //    We retain booking business records but scrub all PII fields.
  const bookingsSnap = await db.collection('bookings').where('userId', '==', userId).get();
  bookingsSnap.forEach((doc) => {
    batch.update(doc.ref, {
      userId: 'DELETED',
      // Retain booking reference code, dates, and price for business records
      // but clear any PII contact or special requests
      pickupLocation: admin.firestore.FieldValue.delete(),
      specialRequests: admin.firestore.FieldValue.delete(),
      deletedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  // 6. SECURITY FIX #12: Delete user's reviews
  // We query all tours and find reviews by this user
  // This is limited to a shallow query approach given Firestore collection group queries
  const reviewsSnap = await db.collectionGroup('reviews').where('userId', '==', userId).get();
  reviewsSnap.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // 7. Delete user document itself
  batch.delete(db.collection('users').doc(userId));

  // Commit all Firestore changes
  await batch.commit();

  // 8. Delete Storage objects for this user. If this fails, the caller should
  // stop before deleting the auth identity.
  await bucket.deleteFiles({ prefix: `users/${userId}/` });
  await bucket.deleteFiles({ prefix: `concierge_threads/${userId}/attachments/` });

  return { success: true };
}
