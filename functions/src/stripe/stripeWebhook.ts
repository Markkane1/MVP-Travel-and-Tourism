import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';
import { confirmBookingLogic } from '../bookings/confirmBooking';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'sk_test_mock', {
  apiVersion: '2023-10-16',
});

const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

export const stripeWebhook = onRequest(async (request, response) => {
  // SECURITY FIX #9: Fail closed — do not proceed if the webhook secret is
  // not configured. Shipping a known fallback secret allows forged events.
  if (!endpointSecret) {
    console.error('STRIPE_WEBHOOK_SECRET is not set. Rejecting webhook request.');
    response.status(500).send('Webhook secret not configured.');
    return;
  }
  const sig = request.headers['stripe-signature'];

  let event: Stripe.Event;

  try {
    // Verify the webhook signature
    // Firebase functions V2 onRequest gives us request.rawBody which is a Buffer
    event = stripe.webhooks.constructEvent(request.rawBody, sig as string, endpointSecret);
  } catch (err: any) {
    console.error(`Webhook Error: ${err.message}`);
    response.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  // Handle the event
  switch (event.type) {
    case 'payment_intent.succeeded':
      const paymentIntent = event.data.object as Stripe.PaymentIntent;
      const bookingId = paymentIntent.metadata?.bookingId;
      const userId = paymentIntent.metadata?.userId;

      if (bookingId && userId) {
        try {
          const db = admin.firestore();
          await confirmBookingLogic(db, bookingId, userId, paymentIntent.id);
          console.log(`Successfully confirmed booking ${bookingId} via Stripe Webhook`);
        } catch (error) {
          console.error(`Error confirming booking ${bookingId}:`, error);
        }
      } else {
        console.warn('Payment intent succeeded but missing metadata.bookingId or userId');
      }
      break;
    
    // ... handle other event types if necessary
    default:
      console.log(`Unhandled event type ${event.type}`);
  }

  // Return a 200 response to acknowledge receipt of the event
  response.send();
});
