import { Response } from 'express';
import { BookingService } from '../services/BookingService';
import { AuthenticatedRequest } from '../types';

const bookingService = new BookingService();

export class BookingController {
  async createBooking(req: AuthenticatedRequest, res: Response) {
    try {
      const data = { ...req.body, userId: req.user!.id };
      const booking = await bookingService.createBooking(data);
      res.status(201).json(booking);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async getBooking(req: AuthenticatedRequest, res: Response) {
    try {
      const booking = await bookingService.getBookingById(req.params.id as string);
      if (!booking || booking.userId !== req.user!.id) {
        res.status(404).json({ error: 'Booking not found' });
        return;
      }
      res.status(200).json(booking);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  async myBookings(req: AuthenticatedRequest, res: Response) {
    try {
      const bookings = await bookingService.getUserBookings(req.user!.id);
      res.status(200).json(bookings);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  async cancelBooking(req: AuthenticatedRequest, res: Response) {
    try {
      const booking = await bookingService.getBookingById(req.params.id as string);
      if (!booking || booking.userId !== req.user!.id) {
        res.status(404).json({ error: 'Booking not found' });
        return;
      }
      const cancelled = await bookingService.cancelBooking(req.params.id as string);
      res.status(200).json(cancelled);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }
}
