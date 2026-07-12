# Security Audit - MVP Travel and Tourism

Date: 2026-07-11
Repository: `D:\web temps\MVP Travel and Tourism`
Audit type: deep static security review of Flutter client app, admin app, Firebase rules, Cloud Functions, and web/admin bootstraps

## What Was Reviewed

- Firestore rules: `firestore.rules`
- Storage rules: `storage.rules`
- Cloud Functions under `functions/src/**`
- Client and admin auth/bootstrap code under `lib/**` and `admin_app/lib/**`
- Client repositories and direct Firestore/Functions access paths
- Dependency exposure via `npm audit` in `functions/`

## What Was Not Fully Executed

- Emulator rules test run could not be completed because Java is not installed locally, so `npm run test:rules` failed before emulator startup.
- No live DAST/proxy pass was run against a deployed web target in this audit.
- No production IAM / secret-manager inspection was possible from repo contents alone.

## Validated Findings

### 1. Critical - booking confirmation can be triggered without a successful Stripe payment

Severity: Critical

Evidence:
- `functions/src/index.ts:13-29` exports a callable `confirmBooking` function directly to authenticated clients.
- `functions/src/bookings/confirmBooking.ts:59-118` confirms the booking, generates a reference code, overwrites price, and awards loyalty points.
- The callable path does not require any verified Stripe event or payment intent.

Impact:
- Any authenticated user can confirm their own pending booking without paying.
- The same path also awards loyalty points and creates a booking confirmation notification.
- This breaks payment integrity completely.

Why this is exploitable:
- The function only checks `request.auth` and booking ownership.
- There is no server-side proof that Stripe ever collected funds before status changes to `confirmed`.

Recommended fix:
- Remove the public callable `confirmBooking` entirely.
- Keep booking confirmation exclusively behind the verified Stripe webhook path.
- Add a regression test proving unauthenticated or unpaid clients cannot move a booking to `confirmed`.

### 2. High - review creation rules and review trigger allow loyalty-point fraud and fake reviews

Severity: High

Evidence:
- `firestore.rules:102-106` allows review creation if the caller is authenticated, the supplied `userId` matches `request.auth.uid`, and `request.resource.data.text.size() <= 2000`.
- The rule does not verify:
  - booking ownership
  - booking completion
  - tour / booking match
  - one-review-per-booking
- The client actually writes `comment`, not `text`, in `lib/features/reviews/data/reviews_repository.dart:48-64`, so the rule's text-length guard is bypassed for normal client submissions.
- `functions/src/reviews/onReviewSubmitted.ts:21-44` awards `250` loyalty points and marks `bookings/{bookingId}.reviewed = true` based only on the review payload's `userId` and `bookingId`.
- The test suite claims stronger protections exist in `functions/test/rules.test.js:116-150`, but the rules do not implement those checks.

Impact:
- A signed-in user can submit a review before completing a trip.
- A signed-in user can bind a review to any unreviewed booking ID they know, not just their own completed booking.
- The trigger can award points fraudulently and mark unrelated bookings as reviewed.
- Review content moderation and length enforcement are weaker than the tests imply.

Recommended fix:
- Enforce booking ownership, completed status, and `booking.tourId == {tourId}` in Firestore rules.
- Align the rules with the actual payload field name (`comment`) or rename the client field to match.
- In `onReviewSubmitted`, re-verify booking ownership and completed status before awarding points.
- Add emulator tests for cross-user booking IDs and non-completed bookings.

### 3. High - Firestore admin authorization trusts any `staff_profiles` document and ignores `isActive`

Severity: High

Evidence:
- `firestore.rules:18-24` defines `hasStaffProfile()` as document existence only, and `isAdmin()` as `isBootstrapAdmin() || hasStaffProfile()`.
- `firestore.rules:26-29` uses the same existence-based model for `isSuperAdmin()`, checking role but still not `isActive`.
- This admin predicate gates broad sensitive access, including:
  - `staff_profiles` read: `firestore.rules:33-37`
  - `admin_audit_logs` read/create: `firestore.rules:42-45`
  - all user profiles: `firestore.rules:49-59`
  - all bookings: `firestore.rules:70-94`
  - all tours/services writes: `firestore.rules:98-113`
  - all concierge threads and messages: `firestore.rules:122-140`
- `functions/src/admin/adminManageStaff.ts:74-78` marks staff inactive in Firestore, but the rules never check `isActive`.

Impact:
- Any account with a surviving `staff_profiles/{uid}` document is treated as an admin at the Firestore rules layer.
- Inactive staff remain authorized by rules as long as they still present a valid token.
- Least-privilege role separation is not enforced in rules.

Recommended fix:
- Change `isAdmin()` and `isSuperAdmin()` to read the profile and require `isActive == true`.
- Consider moving rules authorization to custom claims plus revocation checks, or at minimum require both claim and active profile.
- Add rules tests for inactive staff and role-specific access.

### 4. High - deactivated staff can retain privileged access until token expiry or refresh

Severity: High

Evidence:
- `functions/src/admin/adminManageStaff.ts:69-78` deactivates a staff user by setting `disabled: true` and `isActive: false`.
- The same function does not call `admin.auth().revokeRefreshTokens(uid)`.
- Firestore rules still authorize on `staff_profiles` existence only: `firestore.rules:18-24`.
- Admin callables generally trust only `request.auth` custom claims and do not check disabled-state freshness server-side.

Impact:
- A staff member who already holds a valid ID token can keep using it until expiry.
- Because the rules do not enforce `isActive`, the deactivation is not immediate at the Firestore layer.
- This is especially dangerous for recently removed staff or compromised admin sessions.

Recommended fix:
- Revoke refresh tokens during deactivation.
- Enforce `isActive` in rules and check it in sensitive server-side admin paths.
- Force reauthentication / token refresh for admin sessions after privilege changes.

### 5. High - ordinary admins can grant new admin privileges outside the super-admin workflow

Severity: High

Evidence:
- `functions/src/admin/setAdminClaims.ts:11-23` allows any caller with `request.auth.token.admin === true` to grant admin rights.
- `functions/src/admin/setAdminClaims.ts:31-41` writes custom claims and a `staff_profiles` document for the target user.
- By contrast, `functions/src/admin/adminManageStaff.ts:18-27` says staff management is restricted to bootstrap or `super_admin`.

Impact:
- A non-super-admin can onboard or re-promote arbitrary admin users.
- This bypasses the stricter `adminManageStaff` control boundary.
- Any compromised ordinary admin account can expand persistence and lateral control.

Recommended fix:
- Restrict `setAdminClaims` to `super_admin` only, or delete it after bootstrap is complete.
- Do not keep two separate privilege-granting paths with different authorization strength.

### 6. High - hard-coded bootstrap admin identity is trusted by email address alone

Severity: High

Evidence:
- `firestore.rules:14-16` treats `admin@mvptravel.com` with `email_verified == true` as a bootstrap admin.
- `functions/src/admin/setAdminClaims.ts:16` uses the same email-based bootstrap rule.
- `functions/src/admin/adminManageStaff.ts:19` also trusts the same hard-coded bootstrap email.
- `admin_app/lib/core/auth/auth_provider.dart:28-41` elevates the same email to admin UI access when verified.

Impact:
- Administrative trust is anchored to a literal email address rather than a one-time bootstrap migration or a tightly controlled claim.
- If that mailbox is compromised, recreated, or otherwise mismanaged, privileged access follows the email identity automatically.
- This makes permanent security posture depend on one special inbox.

Recommended fix:
- Remove the permanent bootstrap-email path after initial provisioning.
- Use a dedicated super-admin claim or staff-profile process controlled server-side.

### 7. High - App Check is not enforced on callable functions, and the web/admin clients do not establish equivalent protection

Severity: High

Evidence:
- Every callable in `functions/src/**` is declared as plain `onCall(...)` without `enforceAppCheck: true`; examples:
  - `functions/src/index.ts:13,35,59`
  - `functions/src/stripe/createPaymentIntent.ts:13`
  - `functions/src/admin/adminCreateUser.ts:54`
  - `functions/src/admin/adminDeleteUser.ts:61`
  - `functions/src/admin/adminIssueRefund.ts:97`
  - `functions/src/admin/adminManageStaff.ts:99`
  - `functions/src/admin/adminReplyToConciergeThread.ts:64`
  - `functions/src/admin/adminSendNotification.ts:86`
  - `functions/src/admin/adminUpdateBookingStatus.ts:113`
  - `functions/src/admin/adminUpdateUser.ts:76`
  - `functions/src/admin/setAdminClaims.ts:52`
- Main app bootstrap only activates Android/Apple providers and does not configure a web provider: `lib/bootstrap.dart:65-73`.
- Admin app bootstrap does not activate App Check at all: `admin_app/lib/bootstrap.dart:23-46`.

Impact:
- Callable functions can be scripted by any environment that can present a valid Firebase auth token.
- The admin web surface is especially exposed to automated abuse if a session token is stolen or replayed.
- This weakens protection against client impersonation and abuse tooling.

Recommended fix:
- Enable `enforceAppCheck: true` for sensitive callables.
- Add real web App Check bootstrapping for any deployed web/admin clients.
- Explicitly test missing / invalid App Check behavior in function tests.

### 8. High - Stripe refund side effect is executed inside a Firestore transaction callback

Severity: High

Evidence:
- `functions/src/admin/adminIssueRefund.ts:26-53` calls `stripe.refunds.create(...)` inside `db.runTransaction(...)`.

Impact:
- Firestore may retry transaction callbacks.
- Any retry can cause the external Stripe refund call to execute more than once.
- This creates real financial integrity risk: duplicate refunds or partial state divergence between Stripe and Firestore.

Recommended fix:
- Move external Stripe side effects outside the transaction.
- Use idempotency keys and persist refund state transitions carefully.
- Mark refund intent in Firestore first, then execute a single external refund step, then finalize state.

### 9. High - Stripe webhook falls back to a known hard-coded secret when the environment variable is missing

Severity: High

Evidence:
- `functions/src/stripe/stripeWebhook.ts:10` sets `const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET || 'whsec_mock';`
- `functions/src/stripe/stripeWebhook.ts:17-20` accepts any event that verifies against that value.

Impact:
- If the production deployment ever ships without `STRIPE_WEBHOOK_SECRET`, the webhook will accept signatures generated with a predictable public fallback secret.
- Because the webhook then calls `confirmBookingLogic`, forged events could confirm bookings without a legitimate Stripe event.

Recommended fix:
- Fail closed when the webhook secret is missing.
- Do not ship any known fallback secret for production code paths.

### 10. Medium - audit log integrity is not trustworthy because direct client writes are allowed

Severity: Medium

Evidence:
- `firestore.rules:42-45` allows any `isAdmin()` client to create `admin_audit_logs` documents as long as `actorUid == request.auth.uid`.
- The repository already relies on backend-written audit events in admin functions such as:
  - `functions/src/admin/adminUpdateBookingStatus.ts:94-104`
  - `functions/src/admin/adminIssueRefund.ts:77-90`
  - `functions/src/admin/adminSendNotification.ts:72-78`
  - `functions/src/admin/adminManageStaff.ts:81-90`

Impact:
- A privileged client can forge, flood, or shape audit records directly from the frontend.
- Audit history cannot be treated as authoritative evidence of server-side actions.

Recommended fix:
- Make `admin_audit_logs` writeable only by trusted backend code.
- Remove direct client write permission and emit all audit events from functions or server-controlled paths.

### 11. Medium - backend dependency audit reports known vulnerable packages in the Functions stack

Severity: Medium

Evidence:
- `npm audit --json` in `functions/` reported `11` moderate vulnerabilities.
- Directly affected packages include:
  - `firebase-admin`
  - `firebase-functions`
  - `firebase-functions-test`
- Transitive issues include advisories in:
  - `uuid`
  - `ts-deepmerge`
  - `google-gax`
  - `@google-cloud/firestore`
  - `@google-cloud/storage`

Impact:
- Known vulnerable dependencies increase the attack surface and reduce confidence in the backend stack.
- Some fixes require semver-major upgrades, so this likely needs planned remediation rather than ad hoc patching.

Recommended fix:
- Triage and upgrade the Functions dependency stack.
- Re-run `npm audit` after upgrades and keep the report in CI.

### 12. High - account deletion promises a full wipe but leaves user-linked data and storage objects behind

Severity: High

Evidence:
- `functions/src/users/cleanupUserData.ts:13-47` deletes only:
  - `notifications/{uid}/items`
  - `users/{uid}/savedTours`
  - `users/{uid}/paymentMethods`
  - `concierge_threads/{uid}/messages`
  - `concierge_threads/{uid}`
  - `users/{uid}`
- The same cleanup path does not touch user-linked records in:
  - `bookings/{bookingId}` where `userId == uid`
  - `tours/{tourId}/reviews/{reviewId}` where `userId == uid`
  - Firebase Storage paths such as `users/{uid}/**` and `concierge_threads/{uid}/attachments/**`, even though those paths are actively used by the app in:
    - `lib/features/profile/presentation/screens/edit_profile_screen.dart:103`
    - `lib/features/concierge/presentation/screens/concierge_screen.dart:134-135`
    - storage policy at `storage.rules:14-31`
- `lib/core/services/auth_service.dart:352-365` explicitly says cleanup runs "to guarantee compliance with GDPR and avoid orphaned PII" but still deletes the Firebase Auth user even if cleanup throws.
- The user-facing copy also promises a full wipe:
  - `lib/core/constants/app_strings.dart:221-224`
  - `functions/src/admin/adminDeleteUser.ts:6`
  - `admin_app/lib/features/users/widgets/user_detail_dialog.dart:88`

Impact:
- Users and admins are told account deletion removes all data, but bookings, reviews, uploaded profile images, and uploaded concierge attachments can remain behind.
- If cleanup partially fails, the auth identity is still deleted, making remediation harder while orphaned PII remains in Firestore or Storage.
- This is a privacy and data-retention issue, not just a UX mismatch.

Why this is exploitable:
- The code path is the intended deletion workflow, not an edge case.
- A normal account deletion can leave data behind by design.

Recommended fix:
- Redefine deletion semantics and implement them fully: either anonymize retained business records explicitly, or delete all user-linked records and storage objects consistently.
- Do not delete the auth user until cleanup has succeeded or a deliberate anonymization plan has completed.
- Add deletion regression tests covering bookings, reviews, notifications, profile assets, and concierge attachments.

### 13. Medium - Firebase Storage makes the entire `/admin/**` namespace world-readable

Severity: Medium

Evidence:
- `storage.rules:35-40` allows:
  - `allow read: if true;`
  - for every object under `admin/{allPaths=**}`
- The comment says this is intended for tour/service images, but the rule is not limited to image subfolders or public-only asset classes.

Impact:
- Any file ever uploaded under `admin/**` becomes public immediately, whether or not it was meant to be public.
- This is a namespace-design problem: the path name looks like a privileged area, but its ACL is public.
- Future admin uploads such as exports, invoices, booking artifacts, or operational documents could be exposed accidentally.

Why this is exploitable:
- The rule is active now.
- An admin only needs to upload a sensitive file into the wrong path once for it to become public.

Recommended fix:
- Split public marketing/media assets into a dedicated public prefix such as `public/tours/**` and `public/services/**`.
- Lock `admin/**` to authenticated administrative access only.
- Add storage rules tests proving non-public admin artifacts cannot be fetched anonymously.

### 14. Medium - admin media uploads are wired through unsigned Cloudinary, bypassing Firebase auth, App Check, and Storage rules

Severity: Medium

Evidence:
- `admin_app/lib/core/services/cloudinary_service.dart:5-66` implements direct client-side uploads to Cloudinary using an unsigned upload preset.
- The same service is wired into admin content flows:
  - `admin_app/lib/features/tours/widgets/add_tour_dialog.dart:71,118,148`
  - `admin_app/lib/features/tours/widgets/edit_tour_dialog.dart:80,195,225`
  - `admin_app/lib/features/services/widgets/add_service_dialog.dart:29,49,62`
  - `admin_app/lib/features/services/widgets/edit_service_dialog.dart:31,74,87`
- The design explicitly bypasses Firebase Storage and therefore also bypasses:
  - `storage.rules`
  - Firebase-auth-bound object ownership checks
  - any future App Check enforcement on Firebase storage access

Impact:
- Once real Cloudinary credentials are configured, upload authorization lives entirely in the unsigned preset configuration, not in your Firebase security boundary.
- A leaked preset name or an over-broad preset configuration can allow arbitrary third-party uploads outside repo-visible rules.
- File size, type, and folder constraints are no longer centrally enforced by the audited Firebase policy.

Why this is exploitable:
- The code path is already live in the admin app.
- The only reason it is not immediately exploitable from the repo alone is that the placeholder values have not been replaced yet.
- This is a latent-but-production-relevant security architecture issue, not a dead code path.

Recommended fix:
- Route admin uploads through a trusted backend or Firebase Storage with signed/authorized upload flows.
- If Cloudinary must remain, sign uploads server-side and keep preset scope minimal; do not use unsigned presets for admin-originated content.
- Document and test the non-Firebase upload boundary explicitly.

### 15. Medium - `createPaymentIntent` can be replayed indefinitely for the same pending booking, creating unbounded Stripe objects

Severity: Medium

Evidence:
- `functions/src/stripe/createPaymentIntent.ts:13-117` accepts any authenticated owner of a pending booking.
- The function creates a new Stripe customer on every call: `functions/src/stripe/createPaymentIntent.ts:81-85`
- It creates a new ephemeral key on every call: `functions/src/stripe/createPaymentIntent.ts:88-91`
- It creates a new PaymentIntent on every call: `functions/src/stripe/createPaymentIntent.ts:94-106`
- The function does not:
  - persist a canonical pending payment intent id
  - reuse an existing Stripe customer
  - apply an idempotency key
  - rate-limit repeated calls for the same booking

Impact:
- Any authenticated user can script repeated calls and force the backend to create large numbers of Stripe objects for one booking.
- This increases third-party abuse surface, operational noise, and potential cost.
- Combined with missing App Check on callables, automated abuse becomes easier.

Why this is exploitable:
- Ownership of a single pending booking is enough.
- There is no server-side replay suppression.

Recommended fix:
- Store and reuse a server-side payment state per booking.
- Use Stripe idempotency keys tied to the booking and checkout attempt.
- Reuse or lazily create a stable customer record instead of creating one per call.

## Additional Notes

- `functions/test/rules.test.js` contains expectations for review ownership/completion checks that the live rules do not actually enforce. That is a security-process problem in addition to the underlying review vulnerability.
- The Android Firebase client config file `android/app/google-services.json` is tracked in Git, but that file contains public client config, not a server secret, so it is not itself a reportable secret leak.
- Firebase API keys in `lib/firebase_options.dart` and `admin_app/lib/firebase_options.dart` are standard client config and were not counted as secret exposure findings.

## Recommended Immediate Remediation Order

1. Remove the public `confirmBooking` callable.
2. Lock down review creation and fix `onReviewSubmitted`.
3. Fix Firestore admin predicates to require active, intended roles.
4. Close the admin privilege-escalation path in `setAdminClaims`.
5. Enforce App Check on sensitive callables and add web/admin client support.
6. Remove the webhook fallback secret and fix refund transaction structure.
