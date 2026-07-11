import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'sk_test_mock', {
  apiVersion: '2023-10-16', // Use latest API version compatible with your setup
});

/**
 * Creates a Stripe PaymentIntent for a pending booking.
 * Calculates the exact authentic price from Firestore securely.
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

  // Fetch Tour to calculate price
  const tourId = bookingData.tourId;
  const tourRef = db.collection('tours').doc(tourId);
  const tourDoc = await tourRef.get();
  if (!tourDoc.exists) {
    throw new HttpsError('not-found', 'Associated tour not found');
  }

  const tourData = tourDoc.data();
  
  // Calculate authentic price
  const pricePerPerson = tourData?.pricePerPerson || 0;
  const adults = bookingData.adults || 0;
  const children = bookingData.children || 0;
  
  let authenticTotalPrice = pricePerPerson * (adults + (children * 0.5));
  
  const groupSizeOptions = tourData?.groupSizeOptions || [];
  const clientOption = bookingData.groupSizeOption || '';
  const selectedOption = groupSizeOptions.find((opt: any) => opt.label === clientOption);
  if (selectedOption && typeof selectedOption.priceModifier === 'number') {
    authenticTotalPrice += selectedOption.priceModifier;
  }
  
  if (bookingData.privateVehicle === true) {
    authenticTotalPrice += (tourData?.privateVehicleSurcharge || 0);
  }

  // Stripe requires amount in smallest currency unit (e.g. cents)
  // Assuming authenticTotalPrice is in USD dollars
  const amountInCents = Math.round(authenticTotalPrice * 100);

  if (amountInCents <= 0) {
    throw new HttpsError('out-of-range', 'Calculated price is zero or negative.');
  }

  try {
    // 1. Optional: Create or retrieve Stripe Customer
    // For simplicity, we just create an ephemeral customer or omit it if not saving cards.
    // We'll create a customer for the session.
    const customer = await stripe.customers.create({
      metadata: {
        firebaseUID: userId,
      }
    });

    // 2. Create Ephemeral Key
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customer.id },
      { apiVersion: '2023-10-16' }
    );

    // 3. Create PaymentIntent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInCents,
      currency: 'usd',
      customer: customer.id,
      // Automatic payment methods enabled by default
      automatic_payment_methods: {
        enabled: true,
      },
      metadata: {
        bookingId: bookingId,
        userId: userId,
      },
    });

    return {
      paymentIntent: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customer.id,
      publishableKey: process.env.STRIPE_PUBLISHABLE_KEY || 'pk_test_mock',
    };
  } catch (error: any) {
    throw new HttpsError('internal', `Stripe API error: ${error.message}`);
  }
});
