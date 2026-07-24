import { RefundRepository } from '../repositories/RefundRepository';
import { PaymentService } from './PaymentService';
import { RefundStatus } from '@prisma/client';
import Stripe from 'stripe';
import { env } from '../config/env';

const stripe = new Stripe(env.stripeSecretKey);

export class RefundService {
  constructor(
    private readonly refundRepository = new RefundRepository(),
    private readonly paymentService = new PaymentService(),
    private readonly stripeClient = stripe,
  ) {}

  async initiateRefund(paymentId: string, amount: number, reason?: string) {
    const payment = await this.paymentService.getPaymentById(paymentId);
    if (!payment) throw new Error('Payment not found');

    if (payment.status !== 'SUCCEEDED') {
      throw new Error('Only succeeded payments can be refunded');
    }

    if (!Number.isInteger(amount) || amount <= 0) {
      throw new Error('Refund amount must be a positive integer');
    }

    const existingRefunds = await this.refundRepository.findByPaymentId(paymentId);
    const reservedAmount = existingRefunds
      .filter((refund) => refund.status !== 'FAILED')
      .reduce((sum, refund) => sum + refund.amount, 0);

    if (reservedAmount + amount > payment.amount) {
      throw new Error('Refund amount exceeds payment amount');
    }

    const stripeRefund = await this.stripeClient.refunds.create({
      payment_intent: payment.stripeIntentId,
      amount,
      metadata: reason ? { reason } : undefined,
    }, {
      idempotencyKey: `refund-${paymentId}-${reservedAmount}-${amount}`,
    });

    const refund = await this.refundRepository.create({
      paymentId,
      stripeRefundId: stripeRefund.id,
      amount,
      reason,
      status: 'PENDING',
    });

    return refund;
  }

  async getRefundsByPayment(paymentId: string) {
    return this.refundRepository.findByPaymentId(paymentId);
  }

  async getRefundsByPaymentForUser(paymentId: string, userId: string) {
    const payment = await this.paymentService.getPaymentByIdForUser(paymentId, userId);
    if (!payment) {
      throw new Error('Payment not found');
    }

    return this.refundRepository.findByPaymentId(paymentId);
  }

  async processRefundWebhook(stripeRefundId: string, status: RefundStatus) {
    const refund = await this.refundRepository.findByStripeRefundId(stripeRefundId);
    if (!refund) throw new Error('Refund not found');

    if (refund.status === status) {
      return refund;
    }

    const updatedRefund = await this.refundRepository.updateStatus(refund.id, status);

    if (status === 'SUCCEEDED') {
      await this.paymentService.processWebhook(refund.payment.stripeIntentId, 'REFUNDED');
    }

    return updatedRefund;
  }
}
