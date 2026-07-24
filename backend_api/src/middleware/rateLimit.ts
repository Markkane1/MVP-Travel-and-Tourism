import { RequestHandler } from 'express';

type Bucket = {
  count: number;
  resetAt: number;
};

const buckets = new Map<string, Bucket>();

export function rateLimit(windowMs: number, max: number): RequestHandler {
  return (req, res, next) => {
    const now = Date.now();
    const key = `${req.ip}:${req.path}`;
    const bucket = buckets.get(key);

    if (!bucket || bucket.resetAt <= now) {
      buckets.set(key, { count: 1, resetAt: now + windowMs });
      next();
      return;
    }

    bucket.count += 1;
    if (bucket.count > max) {
      res.status(429).json({ error: 'Too many requests' });
      return;
    }

    next();
  };
}
