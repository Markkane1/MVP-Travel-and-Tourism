import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

/**
 * Callable Cloud Function to update user properties by an admin.
 */
export const adminUpdateUserLogic = async (
  db: admin.firestore.Firestore,
  callerAuth: any,
  targetUserId: string,
  updates: {
    displayName?: string;
    tier?: string;
    loyaltyPoints?: number;
    conciergeId?: string;
  }
) => {
  // 1. Verify caller is authorized
  if (callerAuth?.token?.admin !== true) {
    throw new HttpsError(
      'permission-denied',
      'You must be an admin to perform this action.'
    );
  }

  return db.runTransaction(async (transaction) => {
    const userRef = db.collection('users').doc(targetUserId);
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      throw new HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data()!;

    // 2. Build update payload
    const updatePayload: any = {};
    if (updates.displayName !== undefined) updatePayload.displayName = updates.displayName;
    if (updates.tier !== undefined) updatePayload.tier = updates.tier;
    if (updates.loyaltyPoints !== undefined) updatePayload.loyaltyPoints = updates.loyaltyPoints;
    
    // allow setting to null to unassign
    if (updates.conciergeId !== undefined) {
      updatePayload.conciergeId = updates.conciergeId === '' ? null : updates.conciergeId;
    }

    // 3. Update user
    if (Object.keys(updatePayload).length > 0) {
      transaction.update(userRef, updatePayload);
    }

    // 4. Write audit log
    const auditRef = db.collection('admin_audit_logs').doc();
    transaction.set(auditRef, {
      actorUid: callerAuth.uid,
      actorEmail: callerAuth.token.email || 'unknown',
      actorRole: callerAuth.token.role || 'admin',
      action: 'adminUpdateUser',
      targetType: 'user',
      targetId: targetUserId,
      summary: `Updated user profile properties`,
      before: {
        displayName: userData.displayName,
        tier: userData.tier,
        loyaltyPoints: userData.loyaltyPoints,
        conciergeId: userData.conciergeId,
      },
      after: updatePayload,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, updatedFields: Object.keys(updatePayload) };
  });
};

export const adminUpdateUser = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be logged in.');
  }

  const { targetUserId, updates } = request.data;
  if (!targetUserId || typeof targetUserId !== 'string') {
    throw new HttpsError('invalid-argument', 'A valid targetUserId must be provided.');
  }
  if (!updates || typeof updates !== 'object') {
    throw new HttpsError('invalid-argument', 'Valid updates must be provided.');
  }

  return await adminUpdateUserLogic(admin.firestore(), request.auth, targetUserId, updates);
});
