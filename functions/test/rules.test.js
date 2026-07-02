const test = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const projectId = 'demo-mvp-travel';
const bucketUrl = 'gs://demo-mvp-travel.appspot.com';

let testEnv;

function authedDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function authedStorage(uid) {
  return testEnv.authenticatedContext(uid).storage(bucketUrl);
}

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: readFileSync(join(__dirname, '..', '..', 'firestore.rules'), 'utf8'),
    },
    storage: {
      rules: readFileSync(join(__dirname, '..', '..', 'storage.rules'), 'utf8'),
    },
  });
});

test.after(async () => {
  await testEnv.cleanup();
});

test.beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.clearStorage();
});

test('users can write their own profile but not another user profile', async () => {
  const aliceDb = authedDb('alice');
  const bobDb = authedDb('bob');

  await assertSucceeds(
    aliceDb.collection('users').doc('alice').set({
      displayName: 'Alice',
      loyaltyPoints: 0,
    }),
  );

  await assertFails(
    bobDb.collection('users').doc('alice').set({
      displayName: 'Mallory',
    }),
  );
});

test('booking owner can create pending booking but cannot set protected fields', async () => {
  const aliceDb = authedDb('alice');

  await assertSucceeds(
    aliceDb.collection('bookings').doc('booking-ok').set({
      userId: 'alice',
      tourId: 'tour-1',
      status: 'pending',
      totalPrice: 1000,
      currency: 'USD',
    }),
  );

  await assertFails(
    aliceDb.collection('bookings').doc('booking-bad').set({
      userId: 'alice',
      tourId: 'tour-1',
      status: 'pending',
      reviewed: false,
      bookingReferenceCode: 'LT-12345-EXP',
      totalPrice: 1000,
      currency: 'USD',
    }),
  );
});

test('booking owner cannot update protected booking fields', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('bookings').doc('booking-1').set({
      userId: 'alice',
      tourId: 'tour-1',
      status: 'confirmed',
      reviewed: false,
      totalPrice: 1000,
      currency: 'USD',
    });
  });

  const aliceDb = authedDb('alice');

  await assertFails(
    aliceDb.collection('bookings').doc('booking-1').update({
      status: 'completed',
    }),
  );

  await assertFails(
    aliceDb.collection('bookings').doc('booking-1').update({
      reviewed: true,
    }),
  );
});

test('review create requires completed booking ownership and matching tour', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('bookings').doc('booking-1').set({
      userId: 'alice',
      tourId: 'tour-1',
      status: 'completed',
    });
  });

  const aliceDb = authedDb('alice');
  const bobDb = authedDb('bob');

  await assertSucceeds(
    aliceDb.collection('tours').doc('tour-1').collection('reviews').doc('review-1').set({
      bookingId: 'booking-1',
      userId: 'alice',
      userName: 'Alice',
      overallRating: 5,
      aspectRatings: {
        service: 5,
        accommodation: 5,
        activities: 5,
        value: 5,
      },
      comment: 'Great trip',
      photoUrls: [],
    }),
  );

  await assertFails(
    bobDb.collection('tours').doc('tour-1').collection('reviews').doc('review-2').set({
      bookingId: 'booking-1',
      userId: 'bob',
      userName: 'Bob',
      overallRating: 5,
      aspectRatings: {
        service: 5,
        accommodation: 5,
        activities: 5,
        value: 5,
      },
      comment: 'I should not be able to do this',
      photoUrls: [],
    }),
  );
});

test('notification items only allow read flag updates', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore()
      .collection('notifications')
      .doc('alice')
      .collection('items')
      .doc('notif-1')
      .set({
        title: 'Booking Confirmed',
        body: 'Ready to go',
        type: 'booking',
        deepLink: '/trips/booking-1',
        read: false,
      });
  });

  const aliceDb = authedDb('alice');

  await assertSucceeds(
    aliceDb.collection('notifications').doc('alice').collection('items').doc('notif-1').update({
      read: true,
    }),
  );

  await assertFails(
    aliceDb.collection('notifications').doc('alice').collection('items').doc('notif-1').update({
      title: 'Hacked',
    }),
  );
});

test('storage allows own image upload, blocks other user upload, and keeps concierge attachments private', async () => {
  const aliceStorage = authedStorage('alice');
  const bobStorage = authedStorage('bob');

  await assertSucceeds(
    aliceStorage.ref('users/alice/profile.png').putString('image-bytes', 'raw', {
      contentType: 'image/png',
    }),
  );

  await assertFails(
    bobStorage.ref('users/alice/profile.png').putString('image-bytes', 'raw', {
      contentType: 'image/png',
    }),
  );

  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.storage(bucketUrl)
      .ref('concierge_threads/alice/attachments/sample.png')
      .putString('image-bytes', 'raw', {
        contentType: 'image/png',
      });
  });

  await assertSucceeds(
    aliceStorage.ref('concierge_threads/alice/attachments/sample.png').getDownloadURL(),
  );

  await assertFails(
    bobStorage.ref('concierge_threads/alice/attachments/sample.png').getDownloadURL(),
  );
});

test('user-path images stay publicly readable under the current storage model', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.storage(bucketUrl)
      .ref('users/alice/profile.png')
      .putString('image-bytes', 'raw', {
        contentType: 'image/png',
      });
  });

  const publicStorage = testEnv.unauthenticatedContext().storage(bucketUrl);
  const url = await assertSucceeds(
    publicStorage.ref('users/alice/profile.png').getDownloadURL(),
  );

  assert.equal(typeof url, 'string');
});
