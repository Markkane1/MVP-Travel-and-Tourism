import { Request, Response } from 'express';
import { NotificationService } from '../services/NotificationService';
import { UserRepository } from '../repositories/UserRepository';

export class AdminNotificationController {
  constructor(
    private readonly notificationService = new NotificationService(),
    private readonly userRepository = new UserRepository(),
  ) {}

  sendNotification = async (req: Request, res: Response) => {
    try {
      const {
        userId,
        targetUserId,
        targetType = userId || targetUserId ? 'single' : 'all',
        cohortTier,
        type = 'admin',
        title,
        message,
        body,
      } = req.body;
      const text = message ?? body;
      let targets: string[];
      if (targetType === 'single') {
        const target = targetUserId ?? userId;
        if (!target) throw new Error('Target user is required');
        targets = [target];
      } else {
        const users = await this.userRepository.findActiveNotificationTargets(
          targetType === 'cohort' && cohortTier ? String(cohortTier).toUpperCase() : undefined,
        );
        targets = users.map((user) => user.id);
      }

      await Promise.all(
        targets.map((target) =>
          this.notificationService.sendNotification(target, type, title, text),
        ),
      );
      res.status(201).json({ count: targets.length });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };
}
