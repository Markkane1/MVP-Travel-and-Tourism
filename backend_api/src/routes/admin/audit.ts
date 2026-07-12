import { Router } from 'express';
import { AdminAuditController } from '../../controllers/AdminAuditController';
import { requireAuth } from '../../middleware/auth';
import { requireAdmin } from '../../middleware/roles';

const router = Router();
const adminAuditController = new AdminAuditController();

router.use(requireAuth, requireAdmin);

router.get('/', adminAuditController.getLogs);

export default router;
