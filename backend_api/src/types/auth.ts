import { Role, Status, Tier, User } from '@prisma/client';

export type AuthUser = {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: Role;
  status: Status;
  tier: Tier;
  loyaltyPoints: number;
  createdAt: Date;
  updatedAt: Date;
};

export function toAuthUser(user: User): AuthUser {
  const { password, ...safeUser } = user;
  void password;
  return safeUser;
}

export type AuthTokens = {
  accessToken: string;
  refreshToken: string;
};

export type AuthResponse = AuthTokens & {
  user: AuthUser;
};
