import prisma from '../lib/prisma';
import { Prisma, Session } from '@prisma/client';

export class SessionRepository {
  async create(data: Prisma.SessionUncheckedCreateInput): Promise<Session> {
    return prisma.session.create({ data });
  }

  async findByToken(refreshToken: string): Promise<Session | null> {
    return prisma.session.findUnique({ where: { refreshToken } });
  }

  async revoke(id: string): Promise<Session> {
    return prisma.session.update({
      where: { id },
      data: { isRevoked: true },
    });
  }

  async revokeAllForUser(userId: string): Promise<void> {
    await prisma.session.updateMany({
      where: { userId, isRevoked: false },
      data: { isRevoked: true },
    });
  }
}
