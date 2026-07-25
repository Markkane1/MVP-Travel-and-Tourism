import { roleForFirebaseEmail } from '../src/services/AuthService';

test('seeded Firebase admin emails map to exact backend roles', () => {
  expect(roleForFirebaseEmail('superadmin@travelmvp.com')).toBe('SUPER_ADMIN');
  expect(roleForFirebaseEmail('ADMIN@travelmvp.com')).toBe('ADMIN');
});

test('admin-looking customer emails are not promoted', () => {
  expect(roleForFirebaseEmail('notadmin@example.com')).toBe('CUSTOMER');
  expect(roleForFirebaseEmail('travel-admin@example.com')).toBe('CUSTOMER');
});
