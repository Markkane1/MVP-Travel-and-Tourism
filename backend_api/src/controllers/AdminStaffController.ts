import { Request, Response } from 'express';
import { AuthenticatedRequest } from '../types';
import { StaffService } from '../services/StaffService';
import { AuditLogService } from '../services/AuditLogService';

const staffService = new StaffService();
const auditLogService = new AuditLogService();

export class AdminStaffController {
  async listStaff(req: AuthenticatedRequest, res: Response) {
    try {
      const staff = await staffService.listStaffProfiles();
      res.status(200).json(staff);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  async createStaff(req: AuthenticatedRequest, res: Response) {
    try {
      const { userId, ...data } = req.body;
      const staff = await staffService.createStaffProfile(userId, data);

      await auditLogService.logAction({
        actorId: req.user!.id,
        actorEmail: req.user!.email,
        actorRole: req.user!.role,
        action: 'CREATE_STAFF',
        targetType: 'StaffProfile',
        targetId: staff.id,
        summary: `Created staff profile for user ${userId}`,
      });

      res.status(201).json(staff);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async updateStaff(req: AuthenticatedRequest, res: Response) {
    try {
      const staff = await staffService.updateStaffProfile(req.params.id as string, req.body);

      await auditLogService.logAction({
        actorId: req.user!.id,
        actorEmail: req.user!.email,
        actorRole: req.user!.role,
        action: 'UPDATE_STAFF',
        targetType: 'StaffProfile',
        targetId: staff.id,
      });

      res.status(200).json(staff);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async deactivateStaff(req: AuthenticatedRequest, res: Response) {
    try {
      const staff = await staffService.deactivateStaffProfile(req.params.id as string);

      await auditLogService.logAction({
        actorId: req.user!.id,
        actorEmail: req.user!.email,
        actorRole: req.user!.role,
        action: 'DEACTIVATE_STAFF',
        targetType: 'StaffProfile',
        targetId: staff.id,
      });

      res.status(200).json(staff);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
