import { Router } from 'express';
import { AuthController } from '../controllers/AuthController';
import { requireAuth } from '../middleware/auth';

const router = Router();
const authController = new AuthController();

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/firebase', authController.firebase);
router.post('/refresh', authController.refresh);
router.post('/logout', authController.logout);
router.post('/logout-all', requireAuth, authController.logoutAll);
router.get('/me', requireAuth, authController.me);

export default router;
