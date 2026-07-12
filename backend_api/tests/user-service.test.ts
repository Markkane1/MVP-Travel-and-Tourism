import { UserService } from '../src/services/UserService';

test('getProfile strips hashed password from the response', async () => {
  const userRepository = {
    findById: jest.fn().mockResolvedValue({
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
    }),
  };

  const userService = new UserService(userRepository as any);
  const user = await userService.getProfile('user-1');

  expect(user).not.toHaveProperty('password');
  expect(user.email).toBe('test@example.com');
});

test('non-super-admin cannot create a super admin', async () => {
  const userRepository = {
    findByEmail: jest.fn().mockResolvedValue(null),
  };

  const userService = new UserService(userRepository as any);

  await expect(
    userService.adminCreateUser('ADMIN', {
      email: 'boss@example.com',
      password: 'password123',
      firstName: 'Big',
      lastName: 'Boss',
      role: 'SUPER_ADMIN',
    } as any),
  ).rejects.toThrow('Only super admins can create super admins');
});
