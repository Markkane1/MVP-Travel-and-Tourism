import { Response } from 'express';
import { ConciergeService } from '../services/ConciergeService';
import { AuthenticatedRequest } from '../types';

export class ConciergeController {
  constructor(private readonly conciergeService = new ConciergeService()) {}

  getThread = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const thread = await this.conciergeService.getMyThread(req.user!.id);
      res.status(200).json(thread);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };

  getMessages = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const messages = await this.conciergeService.getMessages(req.user!.id);
      res.status(200).json(messages);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };

  sendMessage = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const message = await this.conciergeService.sendMessage(req.user!.id, req.body.content);
      res.status(201).json(message);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };
}
