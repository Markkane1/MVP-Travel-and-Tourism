import prisma from '../lib/prisma';
import { Prisma, Review } from '@prisma/client';

export class ReviewRepository {
  async findById(id: string): Promise<Review | null> {
    return prisma.review.findUnique({ where: { id } });
  }

  async findByBookingId(bookingId: string): Promise<Review | null> {
    return prisma.review.findUnique({ where: { bookingId } });
  }

  async findRecent(limit = 5) {
    return prisma.review.findMany({
      orderBy: { createdAt: 'desc' },
      take: limit,
      include: { user: true },
    });
  }

  async findByTourId(tourId: string, limit = 5) {
    return prisma.review.findMany({
      where: { tourId },
      orderBy: { createdAt: 'desc' },
      take: limit,
      include: { user: true },
    });
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
