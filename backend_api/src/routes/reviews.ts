import { Router } from 'express';
import { ReviewController } from '../controllers/ReviewController';
import { requireAuth } from '../middleware/auth';

const router = Router();
const reviewController = new ReviewController();

router.get('/recent', reviewController.recentReviews as any);
router.get('/tour/:tourId', reviewController.tourReviews as any);

router.use(requireAuth);

router.post('/', reviewController.submitReview as any);
router.patch('/:id', reviewController.updateReview as any);
router.delete('/:id', reviewController.deleteReview as any);

export default router;
