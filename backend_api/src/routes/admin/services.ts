import { Router } from 'express';
import { AdminServiceController } from '../../controllers/AdminServiceController';
import { requireAuth } from '../../middleware/auth';
import { requireAdmin } from '../../middleware/roles';

const router = Router();
const adminServiceController = new AdminServiceController();

router.use(requireAuth, requireAdmin);

router.get('/', adminServiceController.listServices);
router.post('/', adminServiceController.createService);
router.patch('/:id', adminServiceController.updateService);
router.delete('/:id', adminServiceController.deleteService);

export default router;
