import * as admin from 'firebase-admin';

/**
 * Cleanup transaction/batch deletes all user related Firestore documents
 * including subcollections for savedTours, paymentMethods, and notifications.
 */
export async function cleanupUserDataLogic(
  db: admin.firestore.Firestore,
  userId: string
): Promise<{ success: boolean }> {
  const batch = db.batch();

  // 1. Delete notifications items subcollection
  const notificationsItemsRef = db.collection('notifications').doc(userId).collection('items');
  const notificationDocs = await notificationsItemsRef.get();
  notificationDocs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  // Delete root notification doc
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

  // 5. Delete user document
  batch.delete(db.collection('users').doc(userId));

  await batch.commit();
  return { success: true };
}
