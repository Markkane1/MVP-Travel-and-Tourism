import { UserRepository } from '../repositories/UserRepository';
import { BookingRepository } from '../repositories/BookingRepository';
import { SessionRepository } from '../repositories/SessionRepository';
import { AuditLogService } from './AuditLogService';

export class AccountLifecycleService {
  constructor(
    private readonly userRepository = new UserRepository(),
    private readonly bookingRepository = new BookingRepository(),
    private readonly sessionRepository = new SessionRepository(),
    private readonly auditLogService = new AuditLogService(),
  ) {}

  async processUserDeletion(userId: string) {
    const user = await this.userRepository.findById(userId);
    if (!user) throw new Error('User not found');

    // 1. Invalidate all active sessions to force immediate logouts
    await this.sessionRepository.revokeAllForUser(userId);

    // 2. Check financial history
    const bookings = await this.bookingRepository.findByUserId(userId);
    const hasFinancialHistory = bookings.some((booking) =>
      ['CONFIRMED', 'COMPLETED', 'REFUNDED'].includes(booking.status),
    );

    if (!hasFinancialHistory) {
      // Safe to hard delete
      await this.userRepository.delete(userId);
      
      await this.auditLogService.logAction({
        actorId: userId,
        actorEmail: user.email,
        actorRole: user.role,
        action: 'HARD_DELETE_ACCOUNT',
        targetType: 'User',
        targetId: userId,
        summary: 'Account hard deleted due to zero financial history',
        snapshot: {
          before: {
            id: user.id,
            email: user.email,
            status: user.status,
          },
          after: null,
        },
      });
      return { status: 'DELETED' };
    } else {
      // Must anonymize instead of deleting
      const anonymizedEmail = `deleted-${userId}@anonymized.local`;
      await this.userRepository.update(userId, {
        email: anonymizedEmail,
        firstName: 'Deleted',
        lastName: 'User',
        password: 'disabled', // Will prevent any normal logins
        status: 'DELETED',
      });

      await this.auditLogService.logAction({
        actorId: userId,
        actorEmail: user.email,
        actorRole: user.role,
        action: 'ANONYMIZE_ACCOUNT',
        targetType: 'User',
        targetId: userId,
        summary: 'Account anonymized due to existing financial history',
        snapshot: {
          before: {
            id: user.id,
            email: user.email,
            status: user.status,
          },
          after: {
            email: anonymizedEmail,
            status: 'DELETED',
          },
        },
      });
      return { status: 'ANONYMIZED' };
    }
  }
}
