import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { assertActiveSuperAdmin } from './authz';

/**
 * Callable Cloud Function to set the 'admin' custom claim on a user.
 *
 * SECURITY FIX #5: This function is now restricted to super_admin only.
 * Ordinary admins can no longer grant admin privileges — this was an
 * escalation path that allowed any compromised admin to expand access.
 *
 * Bootstrap use: the very first super_admin must be set via the Firebase
 * console / admin SDK directly. Once the first super_admin exists, all
 * further provisioning should go through adminManageStaff.
 */
export const setAdminClaimsLogic = async (
  db: admin.firestore.Firestore,
  callerAuth: any,
  targetEmail: string,
) => {
  await assertActiveSuperAdmin(db, callerAuth);

  try {
    const userRecord = await admin.auth().getUserByEmail(targetEmail);

    await admin.auth().setCustomUserClaims(userRecord.uid, { admin: true });
    await db.collection('staff_profiles').doc(userRecord.uid).set({
      email: targetEmail,
      role: 'admin',
      isActive: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Write audit log from backend (SECURITY FIX #10: backend-only audit writes)
    await db.collection('admin_audit_logs').add({
      actorUid: callerAuth.uid,
      actorEmail: callerAuth.token.email || 'unknown',
      actorRole: 'super_admin',
      action: 'setAdminClaims',
      targetType: 'user',
      targetId: userRecord.uid,
      summary: `Granted admin rights to ${targetEmail}`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, message: `Successfully granted admin rights to ${targetEmail}.` };
  } catch (error: any) {
    if (error.code === 'auth/user-not-found') {
      throw new HttpsError('not-found', 'User with this email does not exist.');
    }
    throw new HttpsError('internal', error.message || 'Unknown error occurred.');
  }
};

export const setAdminClaims = onCall({ enforceAppCheck: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be logged in.');
  }

  const { targetEmail } = request.data;
  if (!targetEmail || typeof targetEmail !== 'string') {
    throw new HttpsError('invalid-argument', 'A valid targetEmail must be provided.');
  }

  return await setAdminClaimsLogic(admin.firestore(), request.auth, targetEmail);
});
