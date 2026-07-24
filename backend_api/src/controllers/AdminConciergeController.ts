import { Response } from 'express';
import { ConciergeService } from '../services/ConciergeService';
import { AuthenticatedRequest } from '../types';

export class AdminConciergeController {
  constructor(private readonly conciergeService = new ConciergeService()) {}

  listThreads = async (_req: AuthenticatedRequest, res: Response) => {
    try {
      const threads = await this.conciergeService.listThreads();
      res.status(200).json(threads);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };

  getMessages = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const messages = await this.conciergeService.getMessages(req.params.userId as string);
      res.status(200).json(messages);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };

  reply = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const targetUserId = req.params.userId as string;
      const adminId = req.user!.id;
      const adminRole = req.user!.role;
      const content = req.body.content;

      const message = await this.conciergeService.replyAsAdmin(
        targetUserId,
        adminId,
        adminRole,
        content,
      );
      res.status(201).json(message);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };
}
