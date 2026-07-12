import { BookingService } from '../src/services/BookingService';
import { PaymentService } from '../src/services/PaymentService';

test('booking creation always starts in pending status', async () => {
  const bookingRepository = {
    create: jest.fn().mockResolvedValue({ id: 'booking-1', status: 'PENDING' }),
  };

  const service = new BookingService(bookingRepository as any);

  await service.createBooking({
    userId: 'user-1',
    tourId: 'tour-1',
    totalAmount: 25000,
    currency: 'USD',
  });

  expect(bookingRepository.create).toHaveBeenCalledWith(
    expect.objectContaining({
      userId: 'user-1',
      tourId: 'tour-1',
      status: 'PENDING',
      totalAmount: 25000,
      currency: 'USD',
    }),
  );
});

test('booking creation accepts tour date and guests from the app flow', async () => {
  const bookingRepository = {
    create: jest.fn().mockResolvedValue({ id: 'booking-1', status: 'PENDING' }),
  };
  const tourRepository = {
    findDateById: jest.fn().mockResolvedValue({
      id: 'date-1',
      tourId: 'tour-1',
      availableSeats: 4,
      priceOverride: null,
      status: 'SCHEDULED',
      tour: { id: 'tour-1', basePrice: 10000, status: 'PUBLISHED' },
    }),
  };

  const service = new BookingService(bookingRepository as any, tourRepository as any);

  await service.createBooking({
    userId: 'user-1',
    tourDateId: 'date-1',
    guests: 2,
  });

  expect(bookingRepository.create).toHaveBeenCalledWith(
    expect.objectContaining({
      userId: 'user-1',
      tourId: 'tour-1',
      totalAmount: 20000,
      status: 'PENDING',
    }),
  );
});

test('payment intent uses booking amount and blocks cross-user access', async () => {
  const bookingService = {
    getBookingById: jest.fn().mockResolvedValue({
      id: 'booking-1',
      userId: 'user-1',
      status: 'PENDING',
      totalAmount: 18000,
      currency: 'USD',
    }),
  };
  const paymentRepository = {
    findLatestByBookingId: jest.fn().mockResolvedValue(null),
    create: jest.fn().mockResolvedValue({
      id: 'payment-1',
      bookingId: 'booking-1',
      stripeIntentId: 'pi_mock_fixed',
      amount: 18000,
      currency: 'USD',
      status: 'PENDING',
    }),
  };

  const service = new PaymentService(paymentRepository as any, bookingService as any);
  const result = await service.createPaymentIntent('user-1', 'booking-1');

  expect(paymentRepository.create).toHaveBeenCalledWith(
    expect.objectContaining({
      bookingId: 'booking-1',
      amount: 18000,
      currency: 'USD',
    }),
  );
  expect(result.payment.amount).toBe(18000);

  await expect(service.createPaymentIntent('user-2', 'booking-1')).rejects.toThrow(
    'Booking not found',
  );
});
