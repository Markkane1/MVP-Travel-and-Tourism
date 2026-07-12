import { Request, Response } from 'express';
import { RefundService } from '../services/RefundService';
import { AuthenticatedRequest } from '../types';

const refundService = new RefundService();

export class RefundController {
  async initiateRefund(req: Request, res: Response) {
    try {
      const { amount, reason } = req.body;
      const refund = await refundService.initiateRefund(req.params.id as string, amount, reason);
      res.status(201).json(refund);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async getRefunds(req: AuthenticatedRequest, res: Response) {
    try {
      const refunds = await refundService.getRefundsByPaymentForUser(
        req.params.id as string,
        req.user!.id,
      );
      res.status(200).json(refunds);
    } catch (error: any) {
      res.status(404).json({ error: error.message });
    }
  }
}
