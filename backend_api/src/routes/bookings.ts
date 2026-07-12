import { Router } from 'express';
import { BookingController } from '../controllers/BookingController';
import { requireAuth } from '../middleware/auth';

const router = Router();
const bookingController = new BookingController();

router.use(requireAuth);

router.post('/', bookingController.createBooking);
router.get('/:id', bookingController.getBooking);
router.post('/:id/cancel', bookingController.cancelBooking);

export default router;
