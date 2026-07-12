import { Router } from 'express';
import { AdminReviewController } from '../../controllers/AdminReviewController';
import { requireAuth } from '../../middleware/auth';
import { requireAdmin } from '../../middleware/roles';

const router = Router();
const adminReviewController = new AdminReviewController();

router.use(requireAuth, requireAdmin);

router.post('/:id/reward', adminReviewController.issueReward);

export default router;
