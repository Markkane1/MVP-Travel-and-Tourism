import { requireAdmin } from '../src/middleware/roles';

function runRequireAdmin(role?: string) {
  const req = role ? { user: { id: 'user-1', role } } : {};
  const res = {
    status: jest.fn().mockReturnThis(),
    json: jest.fn(),
  };
  const next = jest.fn();

  return Promise.resolve(requireAdmin(req as any, res as any, next)).then(() => ({
    res,
    next,
  }));
}

test.each(['ADMIN', 'SUPER_ADMIN'])('%s can pass admin middleware', async (role) => {
  const { res, next } = await runRequireAdmin(role);

  expect(next).toHaveBeenCalled();
  expect(res.status).not.toHaveBeenCalled();
});

test('CUSTOMER cannot pass admin middleware', async () => {
  const { res, next } = await runRequireAdmin('CUSTOMER');

  expect(next).not.toHaveBeenCalled();
  expect(res.status).toHaveBeenCalledWith(403);
});
