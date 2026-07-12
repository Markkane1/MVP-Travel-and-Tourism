import request from 'supertest';
import app from '../../src/app';

const integrationDescribe =
  process.env.RUN_INTEGRATION_TESTS === '1' ? describe : describe.skip;

integrationDescribe('Audit Logs (Phase 9)', () => {
  const superAdmin = {
    email: `audit_admin_${Date.now()}@integrationtest.local`,
    password: 'password123',
    firstName: 'Audit',
    lastName: 'Admin'
  };

  let adminToken: string;
  let createdStaffId: string;

  beforeAll(async () => {
    const registerRes = await request(app).post('/auth/register').send(superAdmin);
    
    const prisma = (await import('../../src/lib/prisma')).default;
    await prisma.user.update({
      where: { id: registerRes.body.user.id },
      data: { role: 'SUPER_ADMIN' }
    });
    await prisma.staffProfile.create({
      data: { userId: registerRes.body.user.id }
    });

    const loginRes = await request(app).post('/auth/login').send({ email: superAdmin.email, password: superAdmin.password });
    adminToken = loginRes.body.accessToken;
  });

  it('should create a staff user and log the audit', async () => {
    const staffUserRes = await request(app).post('/auth/register').send({
      email: `staff_target_${Date.now()}@integrationtest.local`,
      password: 'password123',
      firstName: 'Target',
      lastName: 'Staff'
    });
    const targetUserId = staffUserRes.body.user.id;

    const res = await request(app)
      .post('/admin/staff')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        userId: targetUserId,
        role: 'ADMIN'
      });

    expect(res.status).toBe(201);
    createdStaffId = res.body.id;

    const auditRes = await request(app)
      .get('/admin/audit')
      .set('Authorization', `Bearer ${adminToken}`);
    
    expect(auditRes.status).toBe(200);
    expect(Array.isArray(auditRes.body)).toBeTruthy();
    
    const log = auditRes.body.find((l: any) => l.action === 'CREATE_STAFF' && l.targetId === createdStaffId);
    expect(log).toBeDefined();
    expect(log.actorEmail).toBe(superAdmin.email);
  });
});
