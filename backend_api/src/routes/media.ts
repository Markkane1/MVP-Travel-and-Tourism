import { Router } from 'express';
import { MediaController } from '../controllers/MediaController';
import { requireAuth } from '../middleware/auth';
import { requireAdmin } from '../middleware/roles';

const router = Router();
const mediaController = new MediaController();

router.use(requireAuth);

router.post('/upload-token', mediaController.getUploadToken as any);
router.post('/complete', mediaController.completeUpload as any);
router.delete('/:id', requireAdmin, mediaController.deleteMedia as any);

export default router;
