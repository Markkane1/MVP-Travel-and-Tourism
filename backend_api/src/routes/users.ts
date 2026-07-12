import { Router } from 'express';
import { UserController } from '../controllers/UserController';
import { BookingController } from '../controllers/BookingController';
import { requireAuth } from '../middleware/auth';

const router = Router();
const userController = new UserController();

router.get('/me', requireAuth, userController.me);
router.patch('/me', requireAuth, userController.updateMe);
router.delete('/me', requireAuth, userController.deleteMe);

const bookingController = new BookingController();
router.get('/me/bookings', requireAuth, bookingController.myBookings);

export default router;
