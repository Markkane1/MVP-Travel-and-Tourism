import { Response } from 'express';
import { PaymentService } from '../services/PaymentService';
import { AuthenticatedRequest } from '../types';

const paymentService = new PaymentService();

export class PaymentController {
  async createIntent(req: AuthenticatedRequest, res: Response) {
    try {
      const { bookingId } = req.body;
      const intent = await paymentService.createPaymentIntent(req.user!.id, bookingId);
      res.status(201).json(intent);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async submitManualIntent(req: AuthenticatedRequest, res: Response) {
    try {
      const { bookingId, paymentMethod } = req.body;
      const payment = await paymentService.submitManualPaymentIntent(
        req.user!.id,
        bookingId,
        paymentMethod || '',
      );
      res.status(201).json(payment);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async getPayment(req: AuthenticatedRequest, res: Response) {
    try {
      const payment = await paymentService.getPaymentByIdForUser(
        req.params.id as string,
        req.user!.id,
      );
      if (!payment) {
        res.status(404).json({ error: 'Payment not found' });
        return;
      }
      res.status(200).json(payment);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
