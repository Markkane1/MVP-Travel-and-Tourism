import { Router } from 'express';
import { PaymentController } from '../controllers/PaymentController';
import { RefundController } from '../controllers/RefundController';
import { requireAuth } from '../middleware/auth';

const router = Router();
const paymentController = new PaymentController();

router.use(requireAuth);

router.post('/create-intent', paymentController.createIntent);
router.get('/:id', paymentController.getPayment);

const refundController = new RefundController();
router.get('/:id/refunds', refundController.getRefunds);

export default router;
