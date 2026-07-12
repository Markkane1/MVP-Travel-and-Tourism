import prisma from '../lib/prisma';
import { Prisma, Review } from '@prisma/client';

export class ReviewRepository {
  async findById(id: string): Promise<Review | null> {
    return prisma.review.findUnique({ where: { id } });
  }

  async findByBookingId(bookingId: string): Promise<Review | null> {
    return prisma.review.findUnique({ where: { bookingId } });
  }

  async create(data: Prisma.ReviewUncheckedCreateInput): Promise<Review> {
    return prisma.review.create({ data });
  }

  async update(id: string, data: Prisma.ReviewUncheckedUpdateInput): Promise<Review> {
    return prisma.review.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<Review> {
    return prisma.review.delete({ where: { id } });
  }
}
