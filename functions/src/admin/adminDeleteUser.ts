import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { cleanupUserDataLogic } from '../users/cleanupUserData';
import { assertActiveSuperAdmin } from './authz';

/**
 * Callable Cloud Function to delete a user account and all their data.
 * Restricted to super_admin.
 */
export const adminDeleteUserLogic = async (
  db: admin.firestore.Firestore,
  callerAuth: any,
  targetUid: string,
  reason: string
) => {
  await assertActiveSuperAdmin(db, callerAuth);

  // 2. Fetch user to verify they exist and get info for audit log
  let targetEmail = 'unknown';
  try {
    const userRecord = await admin.auth().getUser(targetUid);
    targetEmail = userRecord.email || 'unknown';
  } catch (error: any) {
    if (error.code === 'auth/user-not-found') {
      throw new HttpsError('not-found', 'The user to delete was not found in Auth.');
    }
    throw new HttpsError('internal', `Error fetching user: ${error.message}`);
  }

  // 3. Delete Firestore/storage data first. If cleanup fails, the auth
  // identity stays intact so the system does not strand orphaned PII.
  await cleanupUserDataLogic(db, targetUid);

  // 4. Delete from Firebase Auth only after cleanup succeeded.
  try {
    await admin.auth().deleteUser(targetUid);
  } catch (error: any) {
    throw new HttpsError('internal', `Failed to delete auth user: ${error.message}`);
  }

  // 5. Write audit log
  await db.collection('admin_audit_logs').add({
    actorUid: callerAuth.uid,
    actorEmail: callerAuth.token.email || 'unknown',
    actorRole: callerAuth.token.super_admin ? 'super_admin' : 'admin',
    action: 'adminDeleteUser',
    targetType: 'user',
    targetId: targetUid,
    summary: `Deleted user ${targetEmail}`,
    reason: reason || 'No reason provided',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, message: `User ${targetUid} deleted successfully.` };
};

export const adminDeleteUser = onCall({ enforceAppCheck: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be logged in.');
  }

  const { targetUid, reason } = request.data;
  if (!targetUid) {
    throw new HttpsError('invalid-argument', 'Missing targetUid.');
  }

  return await adminDeleteUserLogic(admin.firestore(), request.auth, targetUid, reason);
});
