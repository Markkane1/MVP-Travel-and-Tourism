import { Router } from 'express';
import { AdminNotificationController } from '../../controllers/AdminNotificationController';
import { requireAuth } from '../../middleware/auth';
import { requireAdmin } from '../../middleware/roles';

const router = Router();
const adminNotificationController = new AdminNotificationController();

router.use(requireAuth, requireAdmin);

router.post('/send', adminNotificationController.sendNotification);

export default router;
