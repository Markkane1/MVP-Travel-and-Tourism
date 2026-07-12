import { Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { UserRepository } from '../repositories/UserRepository';
import { AuthenticatedRequest } from '../types';
import { env } from '../config/env';
import { toAuthUser } from '../types/auth';

const userRepository = new UserRepository();

export const requireAuth = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, env.jwtSecret) as { userId: string };
    const user = await userRepository.findActiveById(decoded.userId);

    if (!user) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    req.user = toAuthUser(user);
    next();
  } catch (error) {
    res.status(401).json({ error: 'Unauthorized' });
  }
};
