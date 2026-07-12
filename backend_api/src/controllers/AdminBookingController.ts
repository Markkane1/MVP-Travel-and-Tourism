import { Request, Response } from 'express';
import { AuthenticatedRequest } from '../types';
import { BookingService } from '../services/BookingService';
import { PaymentService } from '../services/PaymentService';
import { RefundService } from '../services/RefundService';
import { AuditLogService } from '../services/AuditLogService';

const bookingService = new BookingService();
const paymentService = new PaymentService();
const refundService = new RefundService();
const auditLogService = new AuditLogService();

export class AdminBookingController {
  async updateStatus(req: AuthenticatedRequest, res: Response) {
    try {
      const { status, notes } = req.body;
      const booking = await bookingService.updateBookingStatus(req.params.id as string, status, notes);

      await auditLogService.logAction({
        actorId: req.user!.id,
        actorEmail: req.user!.email,
        actorRole: req.user!.role,
        action: 'UPDATE_BOOKING_STATUS',
        targetType: 'Booking',
        targetId: booking.id,
        summary: `Status changed to ${status}`,
      });

      res.status(200).json(booking);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async refundBooking(req: AuthenticatedRequest, res: Response) {
    try {
      const latestPayment = await paymentService.getLatestPaymentByBookingId(
        req.params.id as string,
      );
      if (!latestPayment) {
        res.status(404).json({ error: 'Payment not found' });
        return;
      }

      const amount = req.body?.amount ?? latestPayment.amount;
      const refund = await refundService.initiateRefund(
        latestPayment.id,
        amount,
        req.body?.reason,
      );

      await auditLogService.logAction({
        actorId: req.user!.id,
        actorEmail: req.user!.email,
        actorRole: req.user!.role,
        action: 'INITIATE_REFUND',
        targetType: 'Refund',
        targetId: refund.id,
        summary: `Refund of ${amount} initiated`,
      });

      res.status(201).json(refund);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }
}
