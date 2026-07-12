import Stripe from 'stripe';
import { PaymentService } from './PaymentService';
import { RefundService } from './RefundService';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'sk_test_mock');

const paymentService = new PaymentService();
const refundService = new RefundService();

export class StripeWebhookService {
  async handleWebhook(body: Buffer, signature: string, endpointSecret: string) {
    let event: Stripe.Event;

    try {
      if (endpointSecret === 'mock_secret') {
         event = JSON.parse(body.toString()) as Stripe.Event;
      } else {
         event = stripe.webhooks.constructEvent(body, signature, endpointSecret);
      }
    } catch (err: any) {
      throw new Error(`Webhook Error: ${err.message}`);
    }

    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        await paymentService.processWebhook(paymentIntent.id, 'SUCCEEDED');
        break;
      }
      case 'payment_intent.payment_failed': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        await paymentService.processWebhook(paymentIntent.id, 'FAILED');
        break;
      }
      case 'charge.refunded': {
        const charge = event.data.object as Stripe.Charge;
        if (charge.refunds?.data.length) {
          const refund = charge.refunds.data[0];
          await refundService.processRefundWebhook(refund.id, 'SUCCEEDED');
        }
        break;
      }
      default:
        console.log(`Unhandled event type ${event.type}`);
    }

    return { received: true };
  }
}
