function getEnv(name: string, defaultValue: string): string {
  return process.env[name] || defaultValue;
}

export const env = {
  port: Number(process.env.PORT || '3000'),
  databaseUrl: getEnv('DATABASE_URL', 'postgresql://postgres:postgres@localhost:5432/travel_mvp?schema=public'),
  jwtSecret: getEnv('JWT_SECRET', 'supersecretkey'),
  jwtRefreshSecret: getEnv('JWT_REFRESH_SECRET', 'supersecretrefreshkey'),
  corsOrigins: getEnv('CORS_ORIGINS', '*')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
  accessTokenExpiresIn: process.env.ACCESS_TOKEN_EXPIRES_IN || '15m',
  refreshTokenExpiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '7d',
  cloudinaryCloudName: getEnv('CLOUDINARY_CLOUD_NAME', 'mvp_travel'),
  cloudinaryApiKey: getEnv('CLOUDINARY_API_KEY', '119691872585863'),
  cloudinaryApiSecret: getEnv('CLOUDINARY_API_SECRET', '7B_aq0bCddFKm96x5wxuLWZD3lg'),
  stripeSecretKey: getEnv('STRIPE_SECRET_KEY', 'sk_test_placeholder'),
  stripeWebhookSecret: getEnv('STRIPE_WEBHOOK_SECRET', 'whsec_test_placeholder'),
  firebaseProjectId: getEnv('FIREBASE_PROJECT_ID', 'mvp-travel-prod'),
};
