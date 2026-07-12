import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import healthRouter from './routes/health';
import authRouter from './routes/auth';
import usersRouter from './routes/users';
import adminUsersRouter from './routes/admin/users';
import adminStaffRouter from './routes/admin/staff';
import bookingsRouter from './routes/bookings';
import paymentsRouter from './routes/payments';
import adminBookingsRouter from './routes/admin/bookings';
import adminPaymentsRouter from './routes/admin/payments';
import webhooksRouter from './routes/webhooks';
import toursRouter from './routes/tours';
import adminToursRouter from './routes/admin/tours';
import adminServicesRouter from './routes/admin/services';
import reviewsRouter from './routes/reviews';
import adminReviewsRouter from './routes/admin/reviews';
import conciergeRouter from './routes/concierge';
import adminConciergeRouter from './routes/admin/concierge';
import adminNotificationsRouter from './routes/admin/notifications';
import mediaRouter from './routes/media';
import notificationsRouter from './routes/notifications';
import adminAuditRouter from './routes/admin/audit';

const app = express();

app.use(helmet());
app.use(cors());

app.use('/webhooks', webhooksRouter);

app.use(express.json());

app.use('/health', healthRouter);
app.use('/auth', authRouter);
app.use('/users', usersRouter);
app.use('/admin/users', adminUsersRouter);
app.use('/admin/staff', adminStaffRouter);
app.use('/bookings', bookingsRouter);
app.use('/payments', paymentsRouter);
app.use('/admin/bookings', adminBookingsRouter);
app.use('/admin/payments', adminPaymentsRouter);
app.use('/tours', toursRouter);
app.use('/admin/tours', adminToursRouter);
app.use('/admin/services', adminServicesRouter);
app.use('/reviews', reviewsRouter);
app.use('/admin/reviews', adminReviewsRouter);
app.use('/concierge', conciergeRouter);
app.use('/notifications', notificationsRouter);
app.use('/admin/concierge', adminConciergeRouter);
app.use('/admin/notifications', adminNotificationsRouter);
app.use('/media', mediaRouter);
app.use('/admin/audit', adminAuditRouter);

export default app;
