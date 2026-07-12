import request from 'supertest';
import app from '../../src/app';

const integrationDescribe =
  process.env.RUN_INTEGRATION_TESTS === '1' ? describe : describe.skip;

integrationDescribe('Auth & User Flows (Phase 2 & 3)', () => {
  const testUser = {
    email: `customer_${Date.now()}@integrationtest.local`,
    password: 'password123',
    firstName: 'Test',
    lastName: 'Customer'
  };

  let accessToken: string;

  it('should register a new customer', async () => {
    const res = await request(app)
      .post('/auth/register')
      .send(testUser);

    if (res.status !== 201) {
      console.log('Register Error:', res.body);
    }

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('accessToken');
    expect(res.body.user).toHaveProperty('email', testUser.email);
    expect(res.body.user.role).toBe('CUSTOMER');
  });

  it('should login the customer', async () => {
    const res = await request(app)
      .post('/auth/login')
      .send({ email: testUser.email, password: testUser.password });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('accessToken');
    accessToken = res.body.accessToken;
  });

  it('should fetch the user profile with the token', async () => {
    const res = await request(app)
      .get('/users/me')
      .set('Authorization', `Bearer ${accessToken}`);

    expect(res.status).toBe(200);
    expect(res.body.email).toBe(testUser.email);
  });
});
