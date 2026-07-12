import { PaymentRepository } from '../repositories/PaymentRepository';
import { BookingService } from './BookingService';
import { Prisma, PaymentStatus } from '@prisma/client';

export class PaymentService {
  constructor(
    private readonly paymentRepository = new PaymentRepository(),
    private readonly bookingService = new BookingService(),
  ) {}

  async createPaymentIntent(userId: string, bookingId: string) {
    const booking = await this.bookingService.getBookingById(bookingId);
    if (!booking || booking.userId !== userId) {
      throw new Error('Booking not found');
    }

    if (booking.status !== 'PENDING') {
      throw new Error('Payment can only be created for pending bookings');
    }

    const existingPayment = await this.paymentRepository.findLatestByBookingId(bookingId);
    if (existingPayment?.status === 'SUCCEEDED') {
      throw new Error('Booking already paid');
    }

    if (existingPayment?.status === 'PENDING') {
      return {
        payment: existingPayment,
        clientSecret: `secret_${existingPayment.stripeIntentId}`,
      };
    }

    const stripeIntentId = `pi_mock_${Date.now()}`;

    const payment = await this.paymentRepository.create({
      bookingId,
      stripeIntentId,
      amount: booking.totalAmount,
      currency: booking.currency,
    });

    return { payment, clientSecret: `secret_${stripeIntentId}` };
  }

  async getPaymentByIdForUser(id: string, userId: string) {
    const payment = await this.paymentRepository.findByIdWithBooking(id);
    if (!payment || payment.booking.userId !== userId) {
      return null;
    }

    return payment;
  }

  async getPaymentById(id: string) {
    return this.paymentRepository.findById(id);
  }

  async getLatestPaymentByBookingId(bookingId: string) {
    return this.paymentRepository.findLatestByBookingId(bookingId);
  }

  async processWebhook(stripeIntentId: string, status: PaymentStatus) {
    const payment = await this.paymentRepository.findByStripeIntentId(stripeIntentId);
    if (!payment) throw new Error('Payment not found');

    if (payment.status === status) {
      return payment;
    }

    const updatedPayment = await this.paymentRepository.updateStatus(payment.id, status);

    if (status === 'SUCCEEDED') {
      await this.bookingService.updateBookingStatus(
        payment.bookingId,
        'CONFIRMED',
        'Payment received',
      );
    } else if (status === 'REFUNDED') {
      await this.bookingService.updateBookingStatus(
        payment.bookingId,
        'REFUNDED',
        'Payment refunded',
      );
    }

    return updatedPayment;
  }
}
