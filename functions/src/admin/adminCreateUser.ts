import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

export const adminCreateUserLogic = async (
  db: admin.firestore.Firestore,
  callerAuth: any,
  payload: {
    email: string;
    password: string;
    displayName: string;
    tier: string;
  }
) => {
  if (callerAuth?.token?.admin !== true) {
    throw new HttpsError(
      'permission-denied',
      'You must be an admin to perform this action.'
    );
  }

  const { email, password, displayName, tier } = payload;
  if (!email || !password || !displayName || !tier) {
    throw new HttpsError('invalid-argument', 'Missing required user fields.');
  }

  const userRecord = await admin.auth().createUser({
    email,
    password,
    displayName,
  });

  await db.collection('users').doc(userRecord.uid).set({
    email,
    displayName,
    tier,
    loyaltyPoints: 0,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await db.collection('admin_audit_logs').add({
    actorUid: callerAuth.uid,
    actorEmail: callerAuth.token.email || 'unknown',
    actorRole: callerAuth.token.role || 'admin',
    action: 'adminCreateUser',
    targetType: 'user',
    targetId: userRecord.uid,
    summary: `Created user ${email}`,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, uid: userRecord.uid };
};

export const adminCreateUser = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be logged in.');
  }

  return await adminCreateUserLogic(admin.firestore(), request.auth, {
    email: request.data.email,
    password: request.data.password,
    displayName: request.data.displayName,
    tier: request.data.tier,
  });
});
