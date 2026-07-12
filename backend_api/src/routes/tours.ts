import { Router } from 'express';
import { TourController } from '../controllers/TourController';

const router = Router();
const tourController = new TourController();

router.get('/', tourController.getTours);
router.get('/:id', tourController.getTour);

export default router;
