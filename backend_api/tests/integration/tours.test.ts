import request from 'supertest';
import app from '../../src/app';

const integrationDescribe =
  process.env.RUN_INTEGRATION_TESTS === '1' ? describe : describe.skip;

integrationDescribe('Tours Flow (Phase 6)', () => {
  const adminUser = {
    email: `admin_${Date.now()}@integrationtest.local`,
    password: 'password123',
    firstName: 'Test',
    lastName: 'Admin'
  };

  let adminToken: string;
  let createdTourId: string;

  beforeAll(async () => {
    const registerRes = await request(app)
      .post('/auth/register')
      .send(adminUser);
    
    const prisma = (await import('../../src/lib/prisma')).default;
    await prisma.user.update({
      where: { id: registerRes.body.user.id },
      data: { role: 'SUPER_ADMIN' }
    });
    await prisma.staffProfile.create({
      data: { userId: registerRes.body.user.id }
    });

    const loginRes = await request(app)
      .post('/auth/login')
      .send({ email: adminUser.email, password: adminUser.password });
    adminToken = loginRes.body.accessToken;
  });

  it('should allow admin to create a tour', async () => {
    const res = await request(app)
      .post('/admin/tours')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        title: 'Integration Test Tour',
        description: 'Testing the backend',
        type: 'GROUP',
        durationDays: 5,
        basePrice: 50000,
        status: 'PUBLISHED'
      });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
    createdTourId = res.body.id;
  });

  it('should list public tours', async () => {
    const res = await request(app).get('/tours');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBeTruthy();
    
    const found = res.body.find((t: any) => t.id === createdTourId);
    expect(found).toBeDefined();
    expect(found.title).toBe('Integration Test Tour');
  });
});
