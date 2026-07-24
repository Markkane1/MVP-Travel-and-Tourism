import { Request, Response } from 'express';
import { AuthService } from '../services/AuthService';
import { AuthenticatedRequest } from '../types';

const authService = new AuthService();

export class AuthController {
  async register(req: Request, res: Response) {
    try {
      const { email, password, firstName, lastName } = req.body;
      const result = await authService.register({
        email,
        password,
        firstName,
        lastName,
      });
      res.status(201).json(result);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;
      const result = await authService.login(email, password);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(401).json({ error: error.message });
    }
  }

  async firebase(req: Request, res: Response) {
    try {
      const { idToken } = req.body;
      if (!idToken) {
        res.status(400).json({ error: 'Firebase ID token required' });
        return;
      }
      const result = await authService.loginWithFirebaseToken(idToken);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(401).json({ error: error.message });
    }
  }

  async refresh(req: Request, res: Response) {
    try {
      const { refreshToken } = req.body;
      if (!refreshToken) {
        res.status(400).json({ error: 'Refresh token required' });
        return;
      }
      const result = await authService.refresh(refreshToken);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(401).json({ error: error.message });
    }
  }

  async logout(req: Request, res: Response) {
    try {
      const { refreshToken } = req.body;
      if (refreshToken) {
        await authService.logout(refreshToken);
      }
      res.status(200).json({ message: 'Logged out successfully' });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  async logoutAll(req: AuthenticatedRequest, res: Response) {
    try {
      if (req.user) {
        await authService.logoutAll(req.user.id);
      }
      res.status(200).json({ message: 'Logged out from all devices' });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  async me(req: AuthenticatedRequest, res: Response) {
    res.status(200).json({ user: req.user });
  }
}
