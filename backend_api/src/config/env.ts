const relaxedEnv = process.env.NODE_ENV === 'development' || process.env.NODE_ENV === 'test';

function getEnv(name: string, defaultValue?: string): string {
  const value = process.env[name];
  if (value) return value;
  if (relaxedEnv && defaultValue !== undefined) return defaultValue;
  throw new Error(`Missing required environment variable: ${name}`);
}

export const env = {
  port: Number(process.env.PORT || '3000'),
  databaseUrl: getEnv('DATABASE_URL', 'postgresql://postgres:postgres@localhost:5432/travel_mvp?schema=public'),
  jwtSecret: getEnv('JWT_SECRET', 'dev-jwt-secret'),
  jwtRefreshSecret: getEnv('JWT_REFRESH_SECRET', 'dev-jwt-refresh-secret'),
  corsOrigins: getEnv('CORS_ORIGINS', '*')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
  accessTokenExpiresIn: process.env.ACCESS_TOKEN_EXPIRES_IN || '15m',
  refreshTokenExpiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '7d',
  cloudinaryCloudName: getEnv('CLOUDINARY_CLOUD_NAME', 'dev-cloud'),
  cloudinaryApiKey: getEnv('CLOUDINARY_API_KEY', 'dev-key'),
  cloudinaryApiSecret: getEnv('CLOUDINARY_API_SECRET', 'dev-secret'),
  stripeSecretKey: getEnv('STRIPE_SECRET_KEY', 'sk_test_placeholder'),
  stripeWebhookSecret: getEnv('STRIPE_WEBHOOK_SECRET', 'whsec_test_placeholder'),
  firebaseProjectId: getEnv('FIREBASE_PROJECT_ID', 'mvp-travel-prod'),
};
