import prisma from '../lib/prisma';
import { Prisma, StaffProfile } from '@prisma/client';

export class StaffRepository {
  async findById(id: string): Promise<StaffProfile | null> {
    return prisma.staffProfile.findUnique({ where: { id } });
  }

  async findByUserId(userId: string): Promise<StaffProfile | null> {
    return prisma.staffProfile.findUnique({ where: { userId } });
  }

  async findActiveByUserId(userId: string): Promise<StaffProfile | null> {
    return prisma.staffProfile.findFirst({
      where: { userId, isActive: true },
    });
  }

  async findAll() {
    return prisma.staffProfile.findMany({
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(data: Prisma.StaffProfileUncheckedCreateInput): Promise<StaffProfile> {
    return prisma.staffProfile.create({ data });
  }

  async update(id: string, data: Prisma.StaffProfileUpdateInput): Promise<StaffProfile> {
    return prisma.staffProfile.update({
      where: { id },
      data,
    });
  }

  async deactivate(id: string): Promise<StaffProfile> {
    return prisma.staffProfile.update({
      where: { id },
      data: { isActive: false },
    });
  }
}
