import { AuditLogRepository } from '../repositories/AuditLogRepository';
import { Prisma, Role } from '@prisma/client';

export class AuditLogService {
  constructor(private readonly auditLogRepository = new AuditLogRepository()) {}

  async logAction(params: {
    actorId: string;
    actorEmail?: string;
    actorRole: Role;
    action: string;
    targetType: string;
    targetId: string;
    summary?: string;
    snapshot?: any;
  }) {
    return this.auditLogRepository.create({
      actorId: params.actorId,
      actorEmail: params.actorEmail,
      actorRole: params.actorRole,
      action: params.action,
      targetType: params.targetType,
      targetId: params.targetId,
      summary: params.summary,
      snapshot: params.snapshot ? (params.snapshot as Prisma.InputJsonValue) : Prisma.JsonNull,
    });
  }

  async getLogs(filters?: { actorId?: string; targetType?: string; targetId?: string; action?: string }) {
    return this.auditLogRepository.findAll(filters);
  }
}
