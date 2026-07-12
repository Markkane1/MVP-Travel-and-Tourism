import { Response } from 'express';
import { UserService } from '../services/UserService';
import { AccountLifecycleService } from '../services/AccountLifecycleService';
import { AuthenticatedRequest } from '../types';

const userService = new UserService();
const accountLifecycleService = new AccountLifecycleService();

export class UserController {
  async me(req: AuthenticatedRequest, res: Response) {
    try {
      const user = await userService.getProfile(req.user!.id);
      res.status(200).json(user);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  async updateMe(req: AuthenticatedRequest, res: Response) {
    try {
      const updatedUser = await userService.updateProfile(req.user!.id, req.body);
      res.status(200).json(updatedUser);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async deleteMe(req: AuthenticatedRequest, res: Response) {
    try {
      const result = await accountLifecycleService.processUserDeletion(req.user!.id);
      res.status(200).json({ message: 'Account processed for deletion', details: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
