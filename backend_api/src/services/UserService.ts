import { UserRepository } from '../repositories/UserRepository';
import { Prisma, Role } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { toAuthUser } from '../types/auth';
import { SessionService } from './SessionService';

export class UserService {
  constructor(
    private readonly userRepository = new UserRepository(),
    private readonly sessionService = new SessionService(),
  ) {}

  async getProfile(userId: string) {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    return toAuthUser(user);
  }

  async updateProfile(userId: string, data: Partial<Prisma.UserUpdateInput>) {
    const updateData: any = { ...data };
    delete updateData.role;
    delete updateData.tier;
    delete updateData.status;

    if (data.password && typeof data.password === 'string') {
      updateData.password = await bcrypt.hash(data.password, 10);
    }

    const user = await this.userRepository.update(userId, updateData);
    return toAuthUser(user);
  }

  async deleteAccount(userId: string) {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    await this.sessionService.revokeAllSessions(userId);
    return this.userRepository.update(userId, { status: 'DELETED' });
  }

  async deleteMe(userId: string) {
    return this.deleteAccount(userId);
  }

  async adminCreateUser(actorRole: Role, data: Prisma.UserCreateInput) {
    const existing = await this.userRepository.findByEmail(data.email);
    if (existing) throw new Error('Email in use');

    if (data.role === 'SUPER_ADMIN' && actorRole !== 'SUPER_ADMIN') {
      throw new Error('Only super admins can create super admins');
    }

    if (!data.password || data.password.length < 8) {
      throw new Error('Password must be at least 8 characters long');
    }

    const user = await this.userRepository.create({
      ...data,
      password: await bcrypt.hash(data.password, 10),
    });

    return toAuthUser(user);
  }

  async adminUpdateUser(actorRole: Role, userId: string, data: Prisma.UserUpdateInput) {
    const existingUser = await this.userRepository.findById(userId);
    if (!existingUser) {
      throw new Error('User not found');
    }

    if (existingUser.role === 'SUPER_ADMIN' && actorRole !== 'SUPER_ADMIN') {
      throw new Error('Only super admins can update super admins');
    }

    if (data.role === 'SUPER_ADMIN' && actorRole !== 'SUPER_ADMIN') {
      throw new Error('Only super admins can assign super admin role');
    }

    if (data.password && typeof data.password === 'string') {
      data.password = await bcrypt.hash(data.password, 10);
    }

    const user = await this.userRepository.update(userId, data);
    return toAuthUser(user);
  }

  async adminDeleteUser(actorRole: Role, userId: string) {
    const existingUser = await this.userRepository.findById(userId);
    if (!existingUser) {
      throw new Error('User not found');
    }

    if (existingUser.role === 'SUPER_ADMIN' && actorRole !== 'SUPER_ADMIN') {
      throw new Error('Only super admins can delete super admins');
    }

    await this.sessionService.revokeAllSessions(userId);
    return this.userRepository.update(userId, { status: 'DELETED' });
  }
}
