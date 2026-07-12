import { Request, Response } from 'express';
import { NotificationService } from '../services/NotificationService';

export class AdminNotificationController {
  constructor(private readonly notificationService = new NotificationService()) {}

  sendNotification = async (req: Request, res: Response) => {
    try {
      const { userId, type, title, message } = req.body;
      const notification = await this.notificationService.sendNotification(userId, type, title, message);
      res.status(201).json(notification);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };
}
