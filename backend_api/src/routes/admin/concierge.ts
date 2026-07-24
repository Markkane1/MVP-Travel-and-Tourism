import { Router } from 'express';
import { AdminConciergeController } from '../../controllers/AdminConciergeController';
import { requireAuth } from '../../middleware/auth';
import { requireAdmin } from '../../middleware/roles';

const router = Router();
const adminConciergeController = new AdminConciergeController();

router.use(requireAuth, requireAdmin);

router.get('/threads', adminConciergeController.listThreads as any);
router.get('/:userId/messages', adminConciergeController.getMessages as any);
router.post('/:userId/reply', adminConciergeController.reply as any);

export default router;
