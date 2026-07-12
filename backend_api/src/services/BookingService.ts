import { BookingRepository } from '../repositories/BookingRepository';
import { Prisma, BookingStatus } from '@prisma/client';
import { TourRepository } from '../repositories/TourRepository';

type CreateBookingInput = {
  userId: string;
  tourId?: string | null;
  tourDateId?: string | null;
  guests?: number;
  serviceId?: string | null;
  totalAmount?: number;
  currency?: string;
};

export class BookingService {
  constructor(
    private readonly bookingRepository = new BookingRepository(),
    private readonly tourRepository = new TourRepository(),
  ) {}

  async createBooking(data: CreateBookingInput) {
    let tourId = data.tourId ?? null;
    let totalAmount = data.totalAmount;

    if (data.tourDateId) {
      const tourDate = await this.tourRepository.findDateById(data.tourDateId);
      if (!tourDate || tourDate.status === 'CANCELLED' || tourDate.tour.status !== 'PUBLISHED') {
        throw new Error('Tour date not available');
      }

      const guests = data.guests ?? 1;
      if (!Number.isInteger(guests) || guests <= 0) {
        throw new Error('Guest count must be a positive integer');
      }
      if (tourDate.availableSeats < guests) {
        throw new Error('Not enough seats available');
      }

      tourId = tourDate.tourId;
      totalAmount = (tourDate.priceOverride ?? tourDate.tour.basePrice) * guests;
    }

    if ((tourId ? 1 : 0) + (data.serviceId ? 1 : 0) !== 1) {
      throw new Error('Booking must reference exactly one tour or service');
    }

    if (!Number.isInteger(totalAmount) || (totalAmount ?? 0) <= 0) {
      throw new Error('Booking amount must be a positive integer');
    }
    const bookingAmount = totalAmount as number;

    return this.bookingRepository.create({
      userId: data.userId,
      tourId,
      serviceId: data.serviceId ?? null,
      totalAmount: bookingAmount,
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
