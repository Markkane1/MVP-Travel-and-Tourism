import { beforeUserCreated } from 'firebase-functions/v2/identity';
import { HttpsError } from 'firebase-functions/v2/https';

/**
 * Blocking Auth trigger that enforces the app's password strength policy
 * server-side: minimum 8 characters and at least one numeric digit.
 *
 * Firebase Auth's own minimum (6 characters) is weaker than this app's stated
 * policy, so this trigger bridges the gap. Passwords submitted via Google/Apple
 * OAuth have no password field and are always allowed through.
 */
export const enforcePasswordPolicy = beforeUserCreated(async (event) => {
  const user = event.data;

  // OAuth users have no password — allow them through unconditionally.
  if (!user.passwordHash) return;

  // The plain-text password is only available during the blocking trigger.
  // It is not stored; we validate and discard it immediately.
  const password: string = (event as any).credential?.password ?? '';

  if (!password) {
    // If we can't inspect the plain-text password, fail closed to be safe.
    throw new HttpsError(
      'invalid-argument',
      'Password could not be validated. Please use the app to register.'
    );
  }

  if (password.length < 8) {
    throw new HttpsError(
      'invalid-argument',
      'Password must be at least 8 characters long.'
    );
  }

  if (!/[0-9]/.test(password)) {
    throw new HttpsError(
      'invalid-argument',
      'Password must contain at least one number.'
    );
  }
});
