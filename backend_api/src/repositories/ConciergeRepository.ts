import prisma from '../lib/prisma';
import { Prisma, ConciergeThread, ConciergeMessage, ThreadStatus } from '@prisma/client';

export class ConciergeRepository {
  async findThreadByUserId(userId: string): Promise<ConciergeThread | null> {
    return prisma.conciergeThread.findUnique({ where: { userId } });
  }

  async findAllThreads(): Promise<ConciergeThread[]> {
    return prisma.conciergeThread.findMany({ orderBy: { updatedAt: 'desc' } });
  }

  async createThread(data: Prisma.ConciergeThreadUncheckedCreateInput): Promise<ConciergeThread> {
    return prisma.conciergeThread.create({ data });
  }

  async getMessagesByThreadId(threadId: string): Promise<ConciergeMessage[]> {
    return prisma.conciergeMessage.findMany({
      where: { threadId },
      orderBy: { createdAt: 'asc' },
    });
  }

  async createMessage(data: Prisma.ConciergeMessageUncheckedCreateInput): Promise<ConciergeMessage> {
    return prisma.conciergeMessage.create({ data });
  }

  async updateThreadStatus(id: string, status: ThreadStatus): Promise<ConciergeThread> {
    return prisma.conciergeThread.update({
      where: { id },
      data: { status },
    });
  }
}
