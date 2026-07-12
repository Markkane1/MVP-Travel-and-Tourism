import { Router } from 'express';
import { ConciergeController } from '../controllers/ConciergeController';
import { requireAuth } from '../middleware/auth';

const router = Router();
const conciergeController = new ConciergeController();

router.use(requireAuth);

router.get('/threads/me', conciergeController.getThread as any);
router.get('/threads/me/messages', conciergeController.getMessages as any);
router.post('/threads/me/messages', conciergeController.sendMessage as any);

export default router;
