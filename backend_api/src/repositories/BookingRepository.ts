import prisma from '../lib/prisma';
import { Prisma, Booking, BookingStatusHistory, BookingStatus } from '@prisma/client';

export class BookingRepository {
  async findById(id: string): Promise<Booking | null> {
    return prisma.booking.findUnique({ where: { id } });
  }

  async findByUserId(userId: string): Promise<Booking[]> {
    return prisma.booking.findMany({ where: { userId } });
  }

  async findAll(): Promise<Booking[]> {
    return prisma.booking.findMany({ orderBy: { createdAt: 'desc' } });
  }

  async create(data: Prisma.BookingUncheckedCreateInput): Promise<Booking> {
    return prisma.$transaction(async (tx) => {
      const booking = await tx.booking.create({ data });

      await tx.bookingStatusHistory.create({
        data: {
          bookingId: booking.id,
          status: booking.status,
          notes: 'Booking created',
        },
      });

      return booking;
    });
  }

  async updateStatus(id: string, status: BookingStatus, notes?: string): Promise<Booking> {
    return prisma.$transaction(async (tx) => {
      const booking = await tx.booking.update({
        where: { id },
        data: { status },
      });

      await tx.bookingStatusHistory.create({
        data: {
          bookingId: id,
          status,
          notes,
        },
      });

      return booking;
    });
  }
}
