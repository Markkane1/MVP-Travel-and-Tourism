import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'sk_test_mock', {
  apiVersion: '2023-10-16',
});

/**
 * Creates a Stripe PaymentIntent for a pending booking.
 * Calculates the exact authentic price from Firestore securely.
 *
 * SECURITY FIX #15: Idempotency \u2014 the function now:
 *   1. Persists the stripeCustomerId on the user document so we reuse one customer per user.
 *   2. Persists the pending stripePaymentIntentId on the booking so repeat calls
 *      return the same intent rather than creating new ones.
 *   3. Uses Stripe idempotency keys tied to the bookingId for safe retries.
 */
export const createPaymentIntent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const bookingId = request.data.bookingId;
  if (!bookingId) {
    throw new HttpsError('invalid-argument', 'The function must be called with a bookingId parameter.');
  }

  const db = admin.firestore();
  const userId = request.auth.uid;

  // Fetch Booking
  const bookingRef = db.collection('bookings').doc(bookingId);
  const bookingDoc = await bookingRef.get();
  if (!bookingDoc.exists) {
    throw new HttpsError('not-found', 'Booking not found');
  }

  const bookingData = bookingDoc.data();
  if (bookingData?.userId !== userId) {
    throw new HttpsError('permission-denied', 'Unauthorized booking ownership');
  }
  if (bookingData?.status !== 'pending') {
    throw new HttpsError('failed-precondition', `Booking is already ${bookingData?.status}`);
  }

  // SECURITY FIX #15: If a payment intent already exists for this booking,
  // return it directly instead of creating a new one.
  if (bookingData?.pendingStripePaymentIntentId) {
    try {
      const existingIntent = await stripe.paymentIntents.retrieve(
        bookingData.pendingStripePaymentIntentId
      );
      if (existingIntent.status === 'requires_payment_method' || existingIntent.status === 'requires_confirmation') {
        // Reuse the existing intent — no new Stripe objects created
        const userDoc = await db.collection('users').doc(userId).get();
        const customerId = userDoc.data()?.stripeCustomerId || existingIntent.customer as string;
        const ephemeralKey = await stripe.ephemeralKeys.create(
          { customer: customerId as string },
          { apiVersion: '2023-10-16' }
        );
        return {
          paymentIntent: existingIntent.client_secret,
          ephemeralKey: ephemeralKey.secret,
          customer: customerId,
          publishableKey: process.env.STRIPE_PUBLISHABLE_KEY || 'pk_test_mock',
        };
      }
    } catch (_) {
      // If retrieval fails, fall through and create a fresh one
    }
  }

  // Fetch Tour to calculate authentic price
  const tourId = bookingData?.tourId;
  const tourRef = db.collection('tours').doc(tourId);
  const tourDoc = await tourRef.get();
  if (!tourDoc.exists) {
    throw new HttpsError('not-found', 'Associated tour not found');
  }

  const tourData = tourDoc.data();
  
  // Calculate authentic price server-side
  const pricePerPerson = tourData?.pricePerPerson || 0;
  const adults = bookingData?.adults || 0;
  const children = bookingData?.children || 0;
  
  let authenticTotalPrice = pricePerPerson * (adults + (children * 0.5));
  
  const groupSizeOptions = tourData?.groupSizeOptions || [];
  const clientOption = bookingData?.groupSizeOption || '';
  const selectedOption = groupSizeOptions.find((opt: any) => opt.label === clientOption);
  if (selectedOption && typeof selectedOption.priceModifier === 'number') {
    authenticTotalPrice += selectedOption.priceModifier;
  }
  
  if (bookingData?.privateVehicle === true) {
    authenticTotalPrice += (tourData?.privateVehicleSurcharge || 0);
  }

  const amountInCents = Math.round(authenticTotalPrice * 100);

  if (amountInCents <= 0) {
    throw new HttpsError('out-of-range', 'Calculated price is zero or negative.');
  }

  try {
    // SECURITY FIX #15: Reuse existing Stripe customer or create one and persist it
    const userDoc = await db.collection('users').doc(userId).get();
    let customerId = userDoc.data()?.stripeCustomerId as string | undefined;
    
    if (!customerId) {
      const customer = await stripe.customers.create({
        metadata: { firebaseUID: userId },
      }, {
        idempotencyKey: `customer-${userId}`,
      });
      customerId = customer.id;
      // Persist the customer ID so we reuse it on every future checkout
      await db.collection('users').doc(userId).update({
        stripeCustomerId: customerId,
      });
    }

    // Create Ephemeral Key
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: '2023-10-16' }
    );

    // Create PaymentIntent with idempotency key so retries are safe
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInCents,
      currency: 'usd',
      customer: customerId,
      automatic_payment_methods: {
        enabled: true,
      },
      metadata: {
        bookingId: bookingId,
        userId: userId,
      },
    }, {
      idempotencyKey: `payment-intent-${bookingId}`,
    });

    // Persist the pending intent ID on the booking to prevent duplicate creation
    await bookingRef.update({
      pendingStripePaymentIntentId: paymentIntent.id,
    });

    return {
      paymentIntent: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customerId,
      publishableKey: process.env.STRIPE_PUBLISHABLE_KEY || 'pk_test_mock',
    };
  } catch (error: any) {
    throw new HttpsError('internal', `Stripe API error: ${error.message}`);
  }
});
