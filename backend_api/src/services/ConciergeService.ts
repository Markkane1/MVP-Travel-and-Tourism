import { ConciergeRepository } from '../repositories/ConciergeRepository';
import { Role } from '@prisma/client';

export class ConciergeService {
  constructor(private readonly conciergeRepository = new ConciergeRepository()) {}

  async getMyThread(userId: string) {
    let thread = await this.conciergeRepository.findThreadByUserId(userId);
    if (!thread) {
      thread = await this.conciergeRepository.createThread({ userId });
    }
    return thread;
  }

  async getMessages(userId: string) {
    const thread = await this.getMyThread(userId);
    return this.conciergeRepository.getMessagesByThreadId(thread.id);
  }

  async sendMessage(userId: string, content: string) {
    if (!content?.trim()) {
      throw new Error('Message content is required');
    }

    const thread = await this.getMyThread(userId);
    
    // Auto-reopen thread if user sends a message
    if (thread.status === 'CLOSED') {
      await this.conciergeRepository.updateThreadStatus(thread.id, 'OPEN');
    }

    return this.conciergeRepository.createMessage({
      threadId: thread.id,
      senderId: userId,
      senderRole: 'CUSTOMER',
      content: content.trim(),
    });
  }

  async replyAsAdmin(
    targetUserId: string,
    adminId: string,
    adminRole: Role,
    content: string,
  ) {
    if (!content?.trim()) {
      throw new Error('Message content is required');
    }

    const thread = await this.conciergeRepository.findThreadByUserId(targetUserId);
    if (!thread) throw new Error('Thread not found for user');

    return this.conciergeRepository.createMessage({
      threadId: thread.id,
      senderId: adminId,
      senderRole: adminRole,
      content: content.trim(),
    });
  }
}
