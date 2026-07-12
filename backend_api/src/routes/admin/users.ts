import { Router } from 'express';
import { AdminUserController } from '../../controllers/AdminUserController';
import { requireAuth } from '../../middleware/auth';
import { requireAdmin } from '../../middleware/roles';

const router = Router();
const adminUserController = new AdminUserController();

router.use(requireAuth, requireAdmin);

router.post('/', adminUserController.createUser);
router.patch('/:id', adminUserController.updateUser);
router.delete('/:id', adminUserController.deleteUser);

export default router;
