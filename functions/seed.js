const admin = require('firebase-admin');

// Initialize using the default credentials (relies on GOOGLE_APPLICATION_CREDENTIALS or local Firebase CLI auth)
admin.initializeApp({
  projectId: 'mvp-travels'
});

async function seed() {
  try {
    const email = 'admin@mvptravel.com';
    const password = 'password123';
    
    console.log('Creating auth user...');
    let user;
    try {
      user = await admin.auth().createUser({
        email: email,
        password: password,
        emailVerified: true,
      });
      console.log('Created new auth user with UID:', user.uid);
    } catch (e) {
      if (e.code === 'auth/email-already-exists') {
        user = await admin.auth().getUserByEmail(email);
        console.log('User already exists. UID:', user.uid);
        await admin.auth().updateUser(user.uid, { password: password });
        console.log('Password reset to password123');
      } else {
        throw e;
      }
    }

    console.log('Setting custom claims...');
    await admin.auth().setCustomUserClaims(user.uid, { admin: true, role: 'super_admin' });
    console.log('Custom claims set successfully.');

    console.log('Creating staff_profiles document...');
    const db = admin.firestore();
    await db.collection('staff_profiles').doc(user.uid).set({
      uid: user.uid,
      email: email,
      role: 'super_admin',
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log('staff_profiles document created.');

    console.log('\\n✅ Seed successful!');
    console.log('Email:', email);
    console.log('Password:', password);
  } catch (err) {
    console.error('Error seeding admin:', err);
  }
}

seed();
