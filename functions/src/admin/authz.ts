import { HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

type CallerAuth = {
  uid?: string;
  token?: {
    admin?: boolean;
    super_admin?: boolean;
  };
};

async function getActiveStaffProfile(
  db: admin.firestore.Firestore,
  uid: string,
): Promise<FirebaseFirestore.DocumentData> {
  const snapshot = await db.collection('staff_profiles').doc(uid).get();
  if (!snapshot.exists || snapshot.data()?.isActive !== true) {
    throw new HttpsError(
      'permission-denied',
      'Your staff account is inactive or missing.',
    );
  }
  return snapshot.data()!;
}

export async function assertActiveAdmin(
  db: admin.firestore.Firestore,
  callerAuth: CallerAuth,
): Promise<FirebaseFirestore.DocumentData> {
  if (!callerAuth?.uid || callerAuth.token?.admin !== true) {
    throw new HttpsError(
      'permission-denied',
      'You must be an active admin to perform this action.',
    );
  }
  return getActiveStaffProfile(db, callerAuth.uid);
}

export async function assertActiveSuperAdmin(
  db: admin.firestore.Firestore,
  callerAuth: CallerAuth,
): Promise<FirebaseFirestore.DocumentData> {
  if (!callerAuth?.uid || callerAuth.token?.super_admin !== true) {
    throw new HttpsError(
      'permission-denied',
      'You must be an active super admin to perform this action.',
    );
  }
  const profile = await getActiveStaffProfile(db, callerAuth.uid);
  if (profile.role !== 'super_admin') {
    throw new HttpsError(
      'permission-denied',
      'You must be an active super admin to perform this action.',
    );
  }
  return profile;
}
