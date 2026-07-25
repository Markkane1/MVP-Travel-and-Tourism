import { Response, NextFunction } from 'express';
import { Role } from '@prisma/client';
import { AuthenticatedRequest } from '../types';
import { StaffRepository } from '../repositories/StaffRepository';

const staffRepository = new StaffRepository();
const privilegedRoles: Role[] = ['ADMIN', 'SUPER_ADMIN', 'CONCIERGE'];

export const requireRole = (roles: Role[]) => {
  return async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    if (!req.user) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    if (!roles.includes(req.user.role)) {
      res.status(403).json({ error: 'Forbidden' });
      return;
    }

    // SUPER_ADMIN and ADMIN bypass the staff profile requirement.
    // Staff profile is only required for CONCIERGE role.
    if (req.user.role === 'CONCIERGE') {
      const staffProfile = await staffRepository.findActiveByUserId(req.user.id);
      if (!staffProfile) {
        res.status(403).json({ error: 'Active staff profile required' });
        return;
      }
    }

    next();
  };
};

export const requireAdmin = requireRole(['ADMIN', 'SUPER_ADMIN']);
export const requireSuperAdmin = requireRole(['SUPER_ADMIN']);
