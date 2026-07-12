import prisma from '../lib/prisma';
import { Prisma, Payment, PaymentStatus } from '@prisma/client';

export class PaymentRepository {
  async findById(id: string): Promise<Payment | null> {
    return prisma.payment.findUnique({ where: { id } });
  }

  async findByIdWithBooking(id: string) {
    return prisma.payment.findUnique({
      where: { id },
      include: { booking: true },
    });
  }

  async findByStripeIntentId(stripeIntentId: string): Promise<Payment | null> {
    return prisma.payment.findUnique({ where: { stripeIntentId } });
  }

  async findLatestByBookingId(bookingId: string): Promise<Payment | null> {
    return prisma.payment.findFirst({
      where: { bookingId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(data: Prisma.PaymentUncheckedCreateInput): Promise<Payment> {
    return prisma.payment.create({ data });
  }

  async updateStatus(id: string, status: PaymentStatus): Promise<Payment> {
    return prisma.payment.update({
      where: { id },
      data: { status },
    });
  }
}
