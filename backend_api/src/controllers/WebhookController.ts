import { Request, Response } from 'express';
import { StripeWebhookService } from '../services/StripeWebhookService';
import { env } from '../config/env';

const stripeWebhookService = new StripeWebhookService();

export class WebhookController {
  async handleStripeWebhook(req: Request, res: Response) {
    const signature = req.headers['stripe-signature'] as string;

    try {
      // req.body must be the raw buffer here
      const result = await stripeWebhookService.handleWebhook(req.body, signature, env.stripeWebhookSecret);
      res.status(200).json(result);
    } catch (error: any) {
      console.error(error.message);
      res.status(400).send(`Webhook Error: ${error.message}`);
    }
  }
}
