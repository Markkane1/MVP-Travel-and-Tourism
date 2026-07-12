import { RefundService } from '../src/services/RefundService';

test('duplicate succeeded payment webhooks are ignored', async () => {
  const paymentRepository = {
    findByStripeIntentId: jest.fn().mockResolvedValue({
      id: 'payment-1',
      bookingId: 'booking-1',
      stripeIntentId: 'pi_123',
      status: 'SUCCEEDED',
    }),
    updateStatus: jest.fn(),
  };
  const bookingService = {
    updateBookingStatus: jest.fn(),
  };

  const { PaymentService: RealPaymentService } = jest.requireActual(
    '../src/services/PaymentService',
  );
  const service = new RealPaymentService(paymentRepository as any, bookingService as any);

  await service.processWebhook('pi_123', 'SUCCEEDED');

  expect(paymentRepository.updateStatus).not.toHaveBeenCalled();
  expect(bookingService.updateBookingStatus).not.toHaveBeenCalled();
});

test('refunds larger than the captured payment are rejected', async () => {
  const paymentService = {
    getPaymentById: jest.fn().mockResolvedValue({
      id: 'payment-1',
      amount: 10000,
      status: 'SUCCEEDED',
    }),
  };
  const refundRepository = {
    findByPaymentId: jest.fn().mockResolvedValue([]),
    create: jest.fn(),
  };

  const refundService = new RefundService(
    refundRepository as any,
    paymentService as any,
  );

  await expect(
    refundService.initiateRefund('payment-1', 15000, 'too much'),
  ).rejects.toThrow('Refund amount exceeds payment amount');

  expect(refundRepository.create).not.toHaveBeenCalled();
});
