import { Router } from 'express';
import { RefundController } from '../../controllers/RefundController';
import { requireAuth } from '../../middleware/auth';
import { requireAdmin } from '../../middleware/roles';

const router = Router();
const refundController = new RefundController();

router.use(requireAuth, requireAdmin);

router.post('/:id/refund', refundController.initiateRefund);

export default router;
