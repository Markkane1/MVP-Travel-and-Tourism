import { Response } from 'express';
import { AuthenticatedRequest } from '../types';
import { UserService } from '../services/UserService';
import { AccountLifecycleService } from '../services/AccountLifecycleService';
import { AuditLogService } from '../services/AuditLogService';

const userService = new UserService();
const accountLifecycleService = new AccountLifecycleService();
const auditLogService = new AuditLogService();

export class AdminUserController {
  async listUsers(req: AuthenticatedRequest, res: Response) {
    try {
      const users = await userService.listUsers();
      res.status(200).json(users);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  async createUser(req: AuthenticatedRequest, res: Response) {
    try {
      const user = await userService.adminCreateUser(req.user!.role, req.body);
      
      await auditLogService.logAction({
        actorId: req.user!.id,
        actorEmail: req.user!.email,
        actorRole: req.user!.role,
        action: 'CREATE_USER',
        targetType: 'User',
        targetId: user.id,
      });

      res.status(201).json(user);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async updateUser(req: AuthenticatedRequest, res: Response) {
    try {
      const user = await userService.adminUpdateUser(
        req.user!.role,
        req.params.id as string,
        req.body,
      );
      
      await auditLogService.logAction({
        actorId: req.user!.id,
        actorEmail: req.user!.email,
        actorRole: req.user!.role,
        action: 'UPDATE_USER',
        targetType: 'User',
        targetId: user.id,
      });

      res.status(200).json(user);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async deleteUser(req: AuthenticatedRequest, res: Response) {
    try {
      const targetId = req.params.id as string;
      const result = await accountLifecycleService.processUserDeletion(targetId);
      
      await auditLogService.logAction({
        actorId: req.user!.id,
        actorEmail: req.user!.email,
        actorRole: req.user!.role,
        action: 'ADMIN_DELETE_USER',
        targetType: 'User',
        targetId: targetId,
        summary: `Admin forced user lifecycle deletion: ${result.status}`,
      });

      res.status(200).json({ message: 'User processed', details: result });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }
}
