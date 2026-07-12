import { Router } from 'express';
import { NotificationController } from '../controllers/NotificationController';
import { requireAuth } from '../middleware/auth';

const router = Router();
const notificationController = new NotificationController();

router.use(requireAuth);

router.get('/me', notificationController.getMyNotifications as any);
router.post('/:id/read', notificationController.markAsRead as any);

export default router;
