import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

/**
 * Callable Cloud Function to broadcast or target notifications.
 */
export const adminSendNotificationLogic = async (
  db: admin.firestore.Firestore,
  callerAuth: any,
  payload: {
    targetType: 'single' | 'all' | 'cohort';
    title: string;
    body: string;
    type?: string;
    deepLink?: string;
    targetUserId?: string;
    cohortTier?: string;
  }
) => {
  // 1. Verify caller is authorized
  if (callerAuth?.token?.admin !== true) {
    throw new HttpsError(
      'permission-denied',
      'You must be an admin to perform this action.'
    );
  }

  const { targetType, title, body, type, deepLink, targetUserId, cohortTier } = payload;
  let targetUids: string[] = [];

  // 2. Resolve Target UIDs
  if (targetType === 'single') {
    if (!targetUserId) throw new HttpsError('invalid-argument', 'targetUserId required for single target.');
    targetUids.push(targetUserId);
  } else if (targetType === 'all') {
    const snap = await db.collection('users').select('id').get();
    targetUids = snap.docs.map(doc => doc.id);
  } else if (targetType === 'cohort') {
    if (!cohortTier) throw new HttpsError('invalid-argument', 'cohortTier required for cohort target.');
    const snap = await db.collection('users').where('tier', '==', cohortTier).select('id').get();
    targetUids = snap.docs.map(doc => doc.id);
  } else {
    throw new HttpsError('invalid-argument', 'Invalid targetType.');
  }

  if (targetUids.length === 0) {
    return { success: true, count: 0, message: 'No targets matched criteria.' };
  }

  // 3. Perform Chunked Writes (max 500 per batch)
  const chunkSize = 500;
  for (let i = 0; i < targetUids.length; i += chunkSize) {
    const chunk = targetUids.slice(i, i + chunkSize);
    const batch = db.batch();

    chunk.forEach(uid => {
      const notifRef = db.collection('notifications').doc(uid).collection('items').doc();
      batch.set(notifRef, {
        title,
        body,
        type: type || 'system',
        deepLink: deepLink || '',
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
  }

  // 4. Write audit log
  await db.collection('admin_audit_logs').add({
    actorUid: callerAuth.uid,
    actorEmail: callerAuth.token.email || 'unknown',
    actorRole: callerAuth.token.role || 'admin',
    action: 'adminSendNotification',
    targetType: targetType,
    summary: `Sent notification to ${targetUids.length} users.`,
    payload: { title, type },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, count: targetUids.length };
};

export const adminSendNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be logged in.');
  }

  const payload = request.data;
  if (!payload || !payload.targetType || !payload.title || !payload.body) {
    throw new HttpsError('invalid-argument', 'Missing required payload fields.');
  }

  return await adminSendNotificationLogic(admin.firestore(), request.auth, payload);
});
