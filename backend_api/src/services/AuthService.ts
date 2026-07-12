import { UserRepository } from '../repositories/UserRepository';
import { SessionService } from './SessionService';
import bcrypt from 'bcryptjs';
import jwt, { SignOptions } from 'jsonwebtoken';
import { User } from '@prisma/client';
import { env } from '../config/env';
import { AuthResponse, AuthTokens, toAuthUser } from '../types/auth';

const userRepository = new UserRepository();
const sessionService = new SessionService();

type RegisterInput = {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
};

export class AuthService {
  async register(data: RegisterInput): Promise<AuthResponse> {
    const existingUser = await userRepository.findByEmail(data.email);
    if (existingUser) {
      throw new Error('Email already in use');
    }

    if (!data.password || data.password.length < 8) {
      throw new Error('Password must be at least 8 characters long');
    }

    const hashedPassword = await bcrypt.hash(data.password, 10);
    const user = await userRepository.create({
      ...data,
      password: hashedPassword,
    });

    return this.generateAuthResponse(user);
  }

  async login(email: string, password: string): Promise<AuthResponse> {
    const user = await userRepository.findByEmail(email);
    if (!user) {
      throw new Error('Invalid credentials');
    }
    if (user.status !== 'ACTIVE') {
      throw new Error('Account is inactive');
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new Error('Invalid credentials');
    }

    return this.generateAuthResponse(user);
  }

  async refresh(refreshToken: string): Promise<AuthResponse> {
    try {
      const decoded = jwt.verify(refreshToken, env.jwtRefreshSecret) as {
        userId: string;
      };
      const session = await sessionService.validateSession(refreshToken);

      if (!session) {
        throw new Error('Invalid session');
      }

      await sessionService.revokeSession(session.id);
      const user = await userRepository.findActiveById(decoded.userId);
      if (!user) {
        throw new Error('Account is inactive');
      }

      return this.generateAuthResponse(user);
    } catch (error) {
      throw new Error('Invalid refresh token');
    }
  }

  async logout(refreshToken: string) {
    const session = await sessionService.validateSession(refreshToken);
    if (session) {
      await sessionService.revokeSession(session.id);
    }
  }

  async logoutAll(userId: string) {
    await sessionService.revokeAllSessions(userId);
  }

  private async generateAuthResponse(user: User): Promise<AuthResponse> {
    const tokens = await this.generateTokens(user);
    return {
      ...tokens,
      user: toAuthUser(user),
    };
  }

  private async generateTokens(user: User): Promise<AuthTokens> {
    const accessTokenOptions: SignOptions = {
      expiresIn: env.accessTokenExpiresIn as SignOptions['expiresIn'],
    };
    const refreshTokenOptions: SignOptions = {
      expiresIn: env.refreshTokenExpiresIn as SignOptions['expiresIn'],
    };
    const accessToken = jwt.sign(
      {
        userId: user.id,
        role: user.role,
        status: user.status,
      },
      env.jwtSecret,
      accessTokenOptions,
    );
    const refreshToken = jwt.sign(
      { userId: user.id },
      env.jwtRefreshSecret,
      refreshTokenOptions,
    );

    await sessionService.createSession(user.id, refreshToken);

    return { accessToken, refreshToken };
  }
}
