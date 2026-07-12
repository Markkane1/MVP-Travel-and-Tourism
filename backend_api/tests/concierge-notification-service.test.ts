import { ConciergeService } from '../src/services/ConciergeService';
import { NotificationService } from '../src/services/NotificationService';

test('concierge reply preserves the actual staff role', async () => {
  const conciergeRepository = {
    findThreadByUserId: jest.fn().mockResolvedValue({
      id: 'thread-1',
      userId: 'user-1',
      status: 'OPEN',
    }),
    createMessage: jest.fn().mockResolvedValue({
      id: 'message-1',
      senderRole: 'CONCIERGE',
    }),
  };

  const service = new ConciergeService(conciergeRepository as any);
  await service.replyAsAdmin('user-1', 'staff-1', 'CONCIERGE', 'Hello there');

  expect(conciergeRepository.createMessage).toHaveBeenCalledWith(
    expect.objectContaining({
      threadId: 'thread-1',
      senderId: 'staff-1',
      senderRole: 'CONCIERGE',
      content: 'Hello there',
    }),
  );
});

test('markNotificationAsRead only marks the users own notification', async () => {
  const notificationRepository = {
    findById: jest.fn().mockResolvedValue({
      id: 'note-1',
      userId: 'user-1',
      isRead: false,
    }),
    markAsRead: jest.fn().mockResolvedValue({
      id: 'note-1',
      userId: 'user-1',
      isRead: true,
    }),
  };

  const service = new NotificationService(notificationRepository as any);

  await expect(service.markNotificationAsRead('user-2', 'note-1')).rejects.toThrow(
    'Notification not found',
  );
  expect(notificationRepository.markAsRead).not.toHaveBeenCalled();
});
