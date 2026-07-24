function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

export const env = {
  port: Number(process.env.PORT || '3000'),
  databaseUrl: requireEnv('DATABASE_URL'),
  jwtSecret: requireEnv('JWT_SECRET'),
  jwtRefreshSecret: requireEnv('JWT_REFRESH_SECRET'),
  corsOrigins: requireEnv('CORS_ORIGINS')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
  accessTokenExpiresIn: process.env.ACCESS_TOKEN_EXPIRES_IN || '15m',
  refreshTokenExpiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '7d',
  cloudinaryCloudName: requireEnv('CLOUDINARY_CLOUD_NAME'),
  cloudinaryApiKey: requireEnv('CLOUDINARY_API_KEY'),
  cloudinaryApiSecret: requireEnv('CLOUDINARY_API_SECRET'),
  stripeSecretKey: requireEnv('STRIPE_SECRET_KEY'),
  stripeWebhookSecret: requireEnv('STRIPE_WEBHOOK_SECRET'),
};
