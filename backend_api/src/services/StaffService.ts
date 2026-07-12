import { StaffRepository } from '../repositories/StaffRepository';
import { Prisma } from '@prisma/client';
import { UserRepository } from '../repositories/UserRepository';

export class StaffService {
  constructor(
    private readonly userRepository = new UserRepository(),
    private readonly staffRepository = new StaffRepository(),
  ) {}

  async createStaffProfile(userId: string, data: Omit<Prisma.StaffProfileUncheckedCreateInput, 'userId'>) {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    if (user.status !== 'ACTIVE') {
      throw new Error('User must be active');
    }

    if (user.role === 'CUSTOMER') {
      throw new Error('Customer accounts cannot have staff profiles');
    }

    const existingProfile = await this.staffRepository.findByUserId(userId);
    if (existingProfile) {
      throw new Error('Staff profile already exists');
    }

    return this.staffRepository.create({
      userId,
      ...data,
    });
  }

  async updateStaffProfile(profileId: string, data: Prisma.StaffProfileUpdateInput) {
    return this.staffRepository.update(profileId, data);
  }

  async deactivateStaffProfile(profileId: string) {
    return this.deactivateStaff(profileId);
  }

  async deactivateStaff(profileId: string) {
    const existingProfile = await this.staffRepository.findById(profileId);
    if (!existingProfile) {
      throw new Error('Staff profile not found');
    }

    const staffProfile = await this.staffRepository.deactivate(profileId);
    await this.userRepository.update(existingProfile.userId, { status: 'INACTIVE' });
    return staffProfile;
  }
}
