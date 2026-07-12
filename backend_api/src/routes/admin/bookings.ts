import { Router } from 'express';
import { AdminBookingController } from '../../controllers/AdminBookingController';
import { requireAuth } from '../../middleware/auth';
import { requireAdmin } from '../../middleware/roles';

const router = Router();
const adminBookingController = new AdminBookingController();

router.use(requireAuth, requireAdmin);

router.post('/:id/status', adminBookingController.updateStatus);
router.post('/:id/refund', adminBookingController.refundBooking);

export default router;
