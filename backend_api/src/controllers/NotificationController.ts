import { Response } from 'express';
import { NotificationService } from '../services/NotificationService';
import { AuthenticatedRequest } from '../types';

export class NotificationController {
  constructor(private readonly notificationService = new NotificationService()) {}

  getMyNotifications = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const notifications = await this.notificationService.getUserNotifications(
        req.user!.id,
      );
      res.status(200).json(notifications);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };

  markAsRead = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const notification = await this.notificationService.markNotificationAsRead(
        req.user!.id,
        req.params.id as string,
      );
      res.status(200).json(notification);
    } catch (error: any) {
      res.status(404).json({ error: error.message });
    }
  };

  markAllAsRead = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const result = await this.notificationService.markAllNotificationsAsRead(
        req.user!.id,
      );
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };
}
