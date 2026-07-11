import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

/**
 * Callable Cloud Function to manage staff profiles and claims.
 */
export const adminManageStaffLogic = async (
  db: admin.firestore.Firestore,
  callerAuth: any,
  payload: {
    action: 'create' | 'updateRole' | 'deactivate';
    uid?: string;
    email?: string;
    password?: string;
    role?: 'admin' | 'super_admin' | 'concierge';
  }
) => {
  // 1. Verify caller is authorized (super_admin or bootstrap)
  const isBootstrap = callerAuth?.token?.email === 'admin@mvptravel.com';
  const isSuperAdmin = callerAuth?.token?.super_admin === true;
  
  if (!isBootstrap && !isSuperAdmin) {
    throw new HttpsError(
      'permission-denied',
      'You must be a super admin to manage staff.'
    );
  }

  const { action, uid, email, password, role } = payload;

  try {
    if (action === 'create') {
      if (!email || !password || !role) {
        throw new HttpsError('invalid-argument', 'Missing fields for creation.');
      }
      
      const userRecord = await admin.auth().createUser({
        email,
        password,
      });

      const claims: any = { admin: true };
      if (role === 'super_admin') claims.super_admin = true;
      if (role === 'concierge') claims.concierge = true;
      await admin.auth().setCustomUserClaims(userRecord.uid, claims);

      await db.collection('staff_profiles').doc(userRecord.uid).set({
        email,
        role,
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    } else if (action === 'updateRole') {
      if (!uid || !role) {
        throw new HttpsError('invalid-argument', 'Missing fields for updateRole.');
      }

      const claims: any = { admin: true };
      if (role === 'super_admin') claims.super_admin = true;
      if (role === 'concierge') claims.concierge = true;
      await admin.auth().setCustomUserClaims(uid, claims);

      await db.collection('staff_profiles').doc(uid).update({
        role,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    } else if (action === 'deactivate') {
      if (!uid) {
        throw new HttpsError('invalid-argument', 'Missing fields for deactivate.');
      }

      await admin.auth().updateUser(uid, { disabled: true });
      await db.collection('staff_profiles').doc(uid).update({
        isActive: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // Write audit log
    await db.collection('admin_audit_logs').add({
      actorUid: callerAuth.uid,
      actorEmail: callerAuth.token.email || 'unknown',
      actorRole: callerAuth.token.role || 'super_admin',
      action: `adminManageStaff_${action}`,
      targetType: 'staff',
      targetId: uid || email,
      summary: `Performed ${action} on staff member`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  } catch (error: any) {
    throw new HttpsError('internal', error.message || 'Error managing staff.');
  }
};

export const adminManageStaff = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be logged in.');
  }
  return await adminManageStaffLogic(admin.firestore(), request.auth, request.data);
});
