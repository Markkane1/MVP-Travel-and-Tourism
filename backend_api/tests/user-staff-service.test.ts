import { UserService } from '../src/services/UserService';
import { StaffService } from '../src/services/StaffService';
import { Status } from '@prisma/client';

describe('UserService', () => {
  it('marks a user as deleted and revokes sessions when deleting their account', async () => {
    const userRepository = {
      findById: jest.fn().mockResolvedValue({ id: 'user-1', status: Status.ACTIVE }),
      update: jest.fn().mockResolvedValue({ id: 'user-1', status: Status.DELETED }),
    };
    const sessionService = {
      revokeAllSessions: jest.fn().mockResolvedValue(undefined),
    };

    const service = new UserService(userRepository as any, sessionService as any);
    const result = await service.deleteMe('user-1');

    expect(userRepository.update).toHaveBeenCalledWith('user-1', { status: Status.DELETED });
    expect(sessionService.revokeAllSessions).toHaveBeenCalledWith('user-1');
    expect(result.status).toBe(Status.DELETED);
  });
});

describe('StaffService', () => {
  it('promotes a user role when creating a staff profile', async () => {
    const userRepository = {
      findById: jest.fn().mockResolvedValue({ id: 'user-2', role: 'CUSTOMER', status: Status.ACTIVE }),
      update: jest.fn().mockResolvedValue({ id: 'user-2', role: 'ADMIN' }),
    };
    const staffRepository = {
      findByUserId: jest.fn().mockResolvedValue(null),
      create: jest.fn().mockResolvedValue({ id: 'staff-1', userId: 'user-2', isActive: true }),
    };

    const service = new StaffService(userRepository as any, staffRepository as any);
    await service.createStaffProfile('user-2', { role: 'ADMIN' });

    expect(userRepository.update).toHaveBeenCalledWith('user-2', { role: 'ADMIN' });
    expect(staffRepository.create).toHaveBeenCalledWith({ userId: 'user-2' });
  });

  it('deactivates a staff profile and marks the user inactive', async () => {
    const staffRepository = {
      findById: jest.fn().mockResolvedValue({ id: 'staff-1', userId: 'user-2', isActive: true }),
      deactivate: jest.fn().mockResolvedValue({ id: 'staff-1', userId: 'user-2', isActive: false }),
    };
    const userRepository = {
      update: jest.fn().mockResolvedValue({ id: 'user-2', status: Status.INACTIVE }),
    };

    const service = new StaffService(userRepository as any, staffRepository as any);
    const result = await service.deactivateStaff('staff-1');

    expect(staffRepository.deactivate).toHaveBeenCalledWith('staff-1');
    expect(userRepository.update).toHaveBeenCalledWith('user-2', { status: Status.INACTIVE });
    expect(result.isActive).toBe(false);
  });
});
