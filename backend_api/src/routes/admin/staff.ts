import { Router } from 'express';
import { AdminStaffController } from '../../controllers/AdminStaffController';
import { requireAuth } from '../../middleware/auth';
import { requireAdmin } from '../../middleware/roles';

const router = Router();
const adminStaffController = new AdminStaffController();

router.use(requireAuth, requireAdmin);

router.get('/', adminStaffController.listStaff);
router.post('/', adminStaffController.createStaff);
router.patch('/:id', adminStaffController.updateStaff);
router.post('/:id/deactivate', adminStaffController.deactivateStaff);

export default router;
