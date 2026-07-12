import request from 'supertest';
import app from '../../src/app';

const integrationDescribe =
  process.env.RUN_INTEGRATION_TESTS === '1' ? describe : describe.skip;

integrationDescribe('Bookings Flow (Phase 4)', () => {
  const customer = {
    email: `customer_${Date.now()}@integrationtest.local`,
    password: 'password123',
    firstName: 'Booking',
    lastName: 'Tester'
  };

  let token: string;
  let tourId: string;
  let tourDateId: string;
  let bookingId: string;

  beforeAll(async () => {
    await request(app).post('/auth/register').send(customer);
    const loginRes = await request(app).post('/auth/login').send({ email: customer.email, password: customer.password });
    token = loginRes.body.accessToken;

    const prisma = (await import('../../src/lib/prisma')).default;
    const tour = await prisma.tour.create({
      data: {
        title: 'Booking Test Tour',
        slug: `booking-test-${Date.now()}`,
        durationDays: 3,
        basePrice: 10000,
        status: 'PUBLISHED',
      }
    });
    tourId = tour.id;

    const tourDate = await prisma.tourDate.create({
      data: {
        tourId,
        startDate: new Date('2026-10-01'),
        endDate: new Date('2026-10-04'),
        capacity: 10,
        availableSeats: 10,
        status: 'SCHEDULED'
      }
    });
    tourDateId = tourDate.id;
  });

  it('should allow customer to book a tour date', async () => {
    const res = await request(app)
      .post('/bookings')
      .set('Authorization', `Bearer ${token}`)
      .send({
        tourDateId,
        guests: 2,
        specialRequirements: 'Vegetarian'
      });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.status).toBe('PENDING');
    bookingId = res.body.id;
  });

  it('should fetch the users bookings', async () => {
    const res = await request(app)
      .get('/users/me/bookings')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBeTruthy();
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body[0].id).toBe(bookingId);
  });
});
