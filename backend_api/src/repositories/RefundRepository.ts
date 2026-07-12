import prisma from '../lib/prisma';
import { Prisma, Refund, RefundStatus } from '@prisma/client';

export class RefundRepository {
  async findById(id: string): Promise<Refund | null> {
    return prisma.refund.findUnique({ where: { id } });
  }

  async findByPaymentId(paymentId: string): Promise<Refund[]> {
    return prisma.refund.findMany({ where: { paymentId } });
  }

  async findByStripeRefundId(stripeRefundId: string) {
    return prisma.refund.findUnique({ where: { stripeRefundId }, include: { payment: true } });
  }

  async create(data: Prisma.RefundUncheckedCreateInput): Promise<Refund> {
    return prisma.refund.create({ data });
  }

  async updateStatus(id: string, status: RefundStatus): Promise<Refund> {
    return prisma.refund.update({
      where: { id },
      data: { status },
    });
  }
}
