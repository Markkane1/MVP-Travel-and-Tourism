import { NotificationRepository } from '../repositories/NotificationRepository';

export class NotificationService {
  constructor(private readonly notificationRepository = new NotificationRepository()) {}

  async sendNotification(userId: string, type: string, title: string, message: string) {
    if (!type?.trim() || !title?.trim() || !message?.trim()) {
      throw new Error('Type, title, and message are required');
    }

    return this.notificationRepository.create({
      userId,
      type: type.trim(),
      title: title.trim(),
      message: message.trim(),
    });
  }

  async getUserNotifications(userId: string) {
    return this.notificationRepository.findByUserId(userId);
  }

  async markNotificationAsRead(userId: string, notificationId: string) {
    const notification = await this.notificationRepository.findById(notificationId);
    if (!notification || notification.userId !== userId) {
      throw new Error('Notification not found');
    }

    return this.notificationRepository.markAsRead(notificationId);
  }

  async markAllNotificationsAsRead(userId: string) {
    return this.notificationRepository.markAllAsRead(userId);
  }
}
