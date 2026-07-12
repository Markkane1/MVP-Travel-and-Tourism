import { SessionRepository } from '../repositories/SessionRepository';
import { Session } from '@prisma/client';
import crypto from 'crypto';

const sessionRepository = new SessionRepository();

export class SessionService {
  async createSession(userId: string, refreshToken: string): Promise<Session> {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7 days expiration
    const refreshTokenHash = this.hashRefreshToken(refreshToken);

    return sessionRepository.create({
      userId,
      refreshToken: refreshTokenHash,
      expiresAt,
    });
  }

  async validateSession(refreshToken: string): Promise<Session | null> {
    const session = await sessionRepository.findByToken(
      this.hashRefreshToken(refreshToken),
    );
    if (!session || session.isRevoked || session.expiresAt < new Date()) {
      return null;
    }
    return session;
  }

  async revokeSession(sessionId: string): Promise<void> {
    await sessionRepository.revoke(sessionId);
  }

  async revokeAllSessions(userId: string): Promise<void> {
    await sessionRepository.revokeAllForUser(userId);
  }

  private hashRefreshToken(refreshToken: string): string {
    return crypto.createHash('sha256').update(refreshToken).digest('hex');
  }
}
