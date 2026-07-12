import { toAuthUser } from '../src/types/auth';

test('toAuthUser removes password from API responses', () => {
  const safe = toAuthUser({
    id: 'user-1',
    email: 'test@example.com',
    password: 'hashed-secret',
    firstName: 'Test',
    lastName: 'User',
    role: 'CUSTOMER',
    status: 'ACTIVE',
    tier: 'STANDARD',
    loyaltyPoints: 0,
    createdAt: new Date('2026-01-01T00:00:00Z'),
    updatedAt: new Date('2026-01-01T00:00:00Z'),
  });

  expect(safe).toEqual(
    expect.objectContaining({
      id: 'user-1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: 'CUSTOMER',
      status: 'ACTIVE',
      tier: 'STANDARD',
      loyaltyPoints: 0,
    }),
  );
  expect(safe).not.toHaveProperty('password');
});
