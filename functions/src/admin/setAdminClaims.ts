import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

/**
 * Callable Cloud Function to set the 'admin' custom claim on a user.
 */
export const setAdminClaimsLogic = async (
  callerAuth: any,
  targetEmail: string,
) => {
  // 1. Verify caller is authorized to make others admin.
  // We allow it if the caller is already an admin, OR if this is the bootstrap user.
  const isCallerAdmin = callerAuth?.token?.admin === true;
  
  // Super admin bootstrap mechanism
  const isBootstrap = targetEmail === 'admin@mvptravel.com';

  if (!isCallerAdmin && !isBootstrap) {
    throw new HttpsError(
      'permission-denied',
      'You must be an admin to grant administrative privileges.'
    );
  }

  try {
    // 2. Look up the target user by email
    const userRecord = await admin.auth().getUserByEmail(targetEmail);

    // 3. Set the custom claim
    await admin.auth().setCustomUserClaims(userRecord.uid, { admin: true });

    // 4. Create/Update a staff profile document
    const db = admin.firestore();
    await db.collection('staff_profiles').doc(userRecord.uid).set({
      email: targetEmail,
      role: 'admin',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    return { success: true, message: `Successfully granted admin rights to ${targetEmail}.` };
  } catch (error: any) {
    if (error.code === 'auth/user-not-found') {
      throw new HttpsError('not-found', 'User with this email does not exist.');
    }
    throw new HttpsError('internal', error.message || 'Unknown error occurred.');
  }
};

export const setAdminClaims = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be logged in.');
  }

  const { targetEmail } = request.data;
  if (!targetEmail || typeof targetEmail !== 'string') {
    throw new HttpsError('invalid-argument', 'A valid targetEmail must be provided.');
  }

  return await setAdminClaimsLogic(request.auth, targetEmail);
});
