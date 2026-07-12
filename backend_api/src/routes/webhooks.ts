import { Router } from 'express';
import express from 'express';
import { WebhookController } from '../controllers/WebhookController';

const router = Router();
const webhookController = new WebhookController();

// Stripe requires the raw body to construct the event
router.post('/stripe', express.raw({ type: 'application/json' }), webhookController.handleStripeWebhook);

export default router;
