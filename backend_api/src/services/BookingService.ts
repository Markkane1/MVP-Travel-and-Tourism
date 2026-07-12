import { BookingRepository } from '../repositories/BookingRepository';
import { Prisma, BookingStatus } from '@prisma/client';

type CreateBookingInput = {
  userId: string;
  tourId?: string | null;
  serviceId?: string | null;
  totalAmount: number;
  currency?: string;
};

export class BookingService {
  constructor(private readonly bookingRepository = new BookingRepository()) {}

  async createBooking(data: CreateBookingInput) {
    if ((data.tourId ? 1 : 0) + (data.serviceId ? 1 : 0) !== 1) {
      throw new Error('Booking must reference exactly one tour or service');
    }

    if (!Number.isInteger(data.totalAmount) || data.totalAmount <= 0) {
      throw new Error('Booking amount must be a positive integer');
    }

    return this.bookingRepository.create({
      userId: data.userId,
      tourId: data.tourId ?? null,
      serviceId: data.serviceId ?? null,
      totalAmount: data.totalAmount,
      currency: data.currency || 'USD',
      status: 'PENDING',
    });
  }

  async getBookingById(id: string) {
    return this.bookingRepository.findById(id);
  }

  async getUserBookings(userId: string) {
    return this.bookingRepository.findByUserId(userId);
  }

  async cancelBooking(id: string) {
    const booking = await this.bookingRepository.findById(id);
    if (!booking) {
      throw new Error('Booking not found');
    }

    if (!['PENDING', 'CONFIRMED'].includes(booking.status)) {
      throw new Error('Booking cannot be cancelled');
    }

    return this.bookingRepository.updateStatus(id, 'CANCELLED', 'Cancelled by user');
  }

  async updateBookingStatus(id: string, status: BookingStatus, notes?: string) {
    const booking = await this.bookingRepository.findById(id);
    if (!booking) {
      throw new Error('Booking not found');
    }

    const allowedTransitions: Record<BookingStatus, BookingStatus[]> = {
      PENDING: ['CONFIRMED', 'CANCELLED'],
      CONFIRMED: ['COMPLETED', 'CANCELLED', 'REFUNDED'],
      CANCELLED: [],
      COMPLETED: ['REFUNDED'],
      REFUNDED: [],
    };

    if (!allowedTransitions[booking.status].includes(status)) {
      throw new Error(`Invalid booking status transition: ${booking.status} -> ${status}`);
    }

    return this.bookingRepository.updateStatus(id, status, notes);
  }
}
