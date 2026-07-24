import { Router } from 'express';
import { AdminTourController } from '../../controllers/AdminTourController';
import { requireAuth } from '../../middleware/auth';
import { requireAdmin } from '../../middleware/roles';

const router = Router();
const adminTourController = new AdminTourController();

router.use(requireAuth, requireAdmin);

router.get('/', adminTourController.listTours);
router.post('/', adminTourController.createTour);
router.patch('/:id', adminTourController.updateTour);
router.delete('/:id', adminTourController.deleteTour);
router.post('/:id/itinerary', adminTourController.addItineraryDay);
router.post('/:id/dates', adminTourController.addTourDate);

export default router;
