import { AccountLifecycleService } from '../src/services/AccountLifecycleService';

test('users without successful financial history are hard deleted', async () => {
  const userRepository = {
    findById: jest.fn().mockResolvedValue({
      id: 'user-1',
      email: 'user@example.com',
      role: 'CUSTOMER',
    }),
    delete: jest.fn().mockResolvedValue({ id: 'user-1' }),
    update: jest.fn(),
  };
  const bookingRepository = {
    findByUserId: jest.fn().mockResolvedValue([]),
  };
  const sessionRepository = {
    revokeAllForUser: jest.fn().mockResolvedValue(undefined),
  };
  const auditLogService = {
    logAction: jest.fn().mockResolvedValue(undefined),
  };

  const service = new AccountLifecycleService(
    userRepository as any,
    bookingRepository as any,
    sessionRepository as any,
    auditLogService as any,
  );
  const result = await service.processUserDeletion('user-1');

  expect(userRepository.delete).toHaveBeenCalledWith('user-1');
  expect(userRepository.update).not.toHaveBeenCalled();
  expect(result.status).toBe('DELETED');
});

test('users with successful financial history are anonymized', async () => {
  const userRepository = {
    findById: jest.fn().mockResolvedValue({
      id: 'user-2',
      email: 'user2@example.com',
      role: 'CUSTOMER',
    }),
    delete: jest.fn(),
    update: jest.fn().mockResolvedValue({ id: 'user-2', status: 'DELETED' }),
  };
  const bookingRepository = {
    findByUserId: jest.fn().mockResolvedValue([
      { id: 'booking-9', status: 'CONFIRMED' },
    ]),
  };
  const sessionRepository = {
    revokeAllForUser: jest.fn().mockResolvedValue(undefined),
  };
  const auditLogService = {
    logAction: jest.fn().mockResolvedValue(undefined),
  };

  const service = new AccountLifecycleService(
    userRepository as any,
    bookingRepository as any,
    sessionRepository as any,
    auditLogService as any,
  );
  const result = await service.processUserDeletion('user-2');

  expect(userRepository.delete).not.toHaveBeenCalled();
  expect(userRepository.update).toHaveBeenCalled();
  expect(result.status).toBe('ANONYMIZED');
});
