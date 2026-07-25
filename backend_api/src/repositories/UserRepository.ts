import prisma from '../lib/prisma';
import { Prisma, User } from '@prisma/client';

function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}

export class UserRepository {
  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { email: normalizeEmail(email) } });
  }

  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  }

  async findActiveById(id: string): Promise<User | null> {
    return prisma.user.findFirst({ where: { id, status: 'ACTIVE' } });
  }

  async findActiveNotificationTargets(tier?: string): Promise<User[]> {
    return prisma.user.findMany({
      where: {
        status: 'ACTIVE',
        role: 'CUSTOMER',
        ...(tier ? { tier: tier as any } : {}),
      },
    });
  }

  async findAll(): Promise<User[]> {
    return prisma.user.findMany({ orderBy: { createdAt: 'desc' } });
  }

  async create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({
      data: { ...data, email: normalizeEmail(data.email) },
    });
  }

  async update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<User> {
    return prisma.user.delete({ where: { id } });
  }
}
