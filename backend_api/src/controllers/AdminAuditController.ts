import { Request, Response } from 'express';
import { AuditLogService } from '../services/AuditLogService';

export class AdminAuditController {
  constructor(private readonly auditLogService = new AuditLogService()) {}

  getLogs = async (req: Request, res: Response) => {
    try {
      const logs = await this.auditLogService.getLogs(req.query);
      res.status(200).json(logs);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };
}
