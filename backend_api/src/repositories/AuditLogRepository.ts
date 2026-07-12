import prisma from '../lib/prisma';
import { Prisma, AuditLog } from '@prisma/client';

export class AuditLogRepository {
  async create(data: Prisma.AuditLogUncheckedCreateInput): Promise<AuditLog> {
    return prisma.auditLog.create({ data });
  }

  async findAll(filters?: { actorId?: string; targetType?: string; targetId?: string; action?: string }): Promise<AuditLog[]> {
    return prisma.auditLog.findMany({
      where: filters,
      orderBy: { createdAt: 'desc' },
      take: 100, // Limit to recent 100 for basic querying
    });
  }
}
