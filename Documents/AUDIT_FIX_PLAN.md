# Audit Fix Plan

This plan fixes the audit findings phase-wise without adding new product features.

## Phase 0: Tooling and Baseline

Goal: make verification possible before refactoring.

Tasks:

1. Put Flutter SDK on PATH or run commands through the installed SDK path.
2. Run `flutter analyze`.
3. Run `flutter test`.
4. Run the app on Android emulator/device.
5. Record current failures without changing behavior.

Exit criteria:

- Analyzer/test commands are runnable.
- Current failures are captured as baseline.

## Phase 1: Restore Architecture Boundaries

Goal: stop presentation from owning backend access.

Tasks:

1. Move checkout `confirmBooking` callable and notification write into checkout data/use-case code.
2. Move trips booking stream and cancellation callable behind an allowed repository/provider boundary.
3. Move concierge Firestore models, seeding, assignment, message stream, send message, and attachment metadata writes into `features/concierge/data/`.
4. Move notifications Firestore stream and read mutations into `features/notifications/data/`.
5. Move profile edit/preferences/settings/payment-method Firestore operations into `features/profile/data/`.
6. Replace cross-feature `data/` and `presentation/` imports with `core/`, navigation, or explicitly exposed providers.

Exit criteria:

- No Firebase/Functions SDK calls remain in `lib/features/*/presentation/`.
- No feature imports another feature's `data/` or `presentation/` internals.

## Phase 2: Normalize Repository Error Handling

Goal: make repository boundaries consistently return handled results.

Tasks:

1. Convert repository write methods from `Future<void>` to `Future<Result<void>>`.
2. Decide the smallest consistent stream strategy: `Stream<Result<T>>` or provider-level mapping.
3. Remove saved-tour `rethrow`; return or emit a failure after rollback.
4. Add focused tests for changed error mapping.

Exit criteria:

- Repository failures do not throw raw backend exceptions into presentation.
- Error UI still receives actionable messages.

## Phase 3: Data Model Alignment

Goal: make models, writes, seed data, rules, and functions use the same fields.

Tasks:

1. Rename tour fields: `rating` to `ratingAverage`, add `ratingCount`.
2. Rename review writes: `rating` to `overallRating`, `aspects` to `aspectRatings`, `images` to `photoUrls`.
3. Decide whether prompt-added fields become official documented model extensions: `reviewed`, `fcmToken`, `deepLink`, `notificationPrefs`, `preferences`, `milesTraveled`, `conciergeId`, `senderType`, `isTyping`.
4. If accepted, document those fields and update rules. If rejected, remove them.
5. Fix payment method field: `cardBrand` to `brand`.

Exit criteria:

- No undocumented Firestore fields remain unless intentionally added to the architecture document.

## Phase 4: Security Rule Tightening

Goal: close permissive rule drift.

Tasks:

1. Remove or justify review update/delete access.
2. Restrict notification writes if they should be backend/service-owned.
3. Restrict `concierge_threads/{uid}` root writes if typing state is function-owned.
4. Revisit public storage reads and split public image paths from private user uploads if needed.
5. Add emulator rule tests for user scope, bookings, review creation, notification policy, and protected booking fields.

Exit criteria:

- Rules match the chosen model and emulator tests pass.

## Phase 5: Design System Cleanup

Goal: remove hardcoded visual drift.

Tasks:

1. Replace raw screen colors with existing tokens or tiny semantic status tokens.
2. Replace ad hoc radii with `AppRadii`.
3. Fix known radius drifts in Explore, Checkout, Profile, Concierge, and Review.
4. Render and compare key screens against the source screenshots.

Exit criteria:

- No raw hex colors remain in screen files.
- Design tokens are used wherever tokens exist.

## Phase 6: File Size and SRP Extraction

Goal: split large files without changing behavior.

Tasks:

1. Extract large screen sections from Booking, Checkout, Profile, Trips, Concierge, Review, Search, Tour Details, and Booking Confirmation.
2. Remove or isolate `widgets_catalog_screen.dart` from production routing.
3. Split shell/placeholder helpers out of `app_router.dart`.

Exit criteria:

- No widget/screen file remains over 250 lines unless explicitly documented.

## Phase 7: Dead Code and Placeholder Removal

Goal: remove incomplete UX paths.

Tasks:

1. Replace or remove the placeholder `/search/results` top-level route.
2. Remove `_PlaceholderScreen` if unused.
3. Implement or remove the dead reviews `See All` action.
4. Remove leftover `Horizon Elite` comment.
5. Reclassify remaining TODOs as documented deferrals or fix them.

Exit criteria:

- `rg "TODO|Horizon Elite|LuxeTravel|Voyage Elite" lib functions/src` has only accepted deferrals.

## Phase 8: Functional Regression Gate

Goal: prove the app still works.

Tasks:

1. Run `flutter analyze`.
2. Run `flutter test`.
3. Run Firebase emulator rule tests if added.
4. Manually run register -> explore -> search -> tour details -> book -> demo checkout -> success -> trips -> review.
5. Run or repair `integration_test/critical_path_test.dart`.

Exit criteria:

- Analyzer passes.
- Tests pass.
- Android happy path passes.

## Recommended Order

1. Phase 0
2. Phase 1
3. Phase 3
4. Phase 4
5. Phase 2
6. Phase 7
7. Phase 5
8. Phase 6
9. Phase 8

Boundaries and data/rule correctness go first because they affect behavior and security. Visual cleanup and extraction are safer after those contracts stop moving.
