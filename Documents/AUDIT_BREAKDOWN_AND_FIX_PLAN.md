# Audit Breakdown and Phase-Wise Fix Plan

Project: MVP Travel and Tourism LLC  
Audit basis: `Documents/01_ARCHITECTURE_AND_DESIGN_SYSTEM.md`, completed prompts in `Documents/02_BUILD_PROMPTS.md`, and current source tree.

This report records violations only. No fixes were applied while preparing it.

## 1. Architecture and Layer Compliance

### 1.1 Presentation Directly Calls Firebase or Cloud Functions

Status: Fail

The architecture requires screens to access Firebase, Storage, Stripe, and Cloud Functions only through feature repositories or services. The following presentation files bypass that boundary:

| File | Line | Violation |
|---|---:|---|
| `lib/features/booking/presentation/screens/booking_screen.dart` | 148 | Uses `FirebaseFirestore.instance` directly to allocate a booking id. |
| `lib/features/checkout/presentation/screens/checkout_screen.dart` | 7 | Imports `cloud_functions` in presentation. |
| `lib/features/checkout/presentation/screens/checkout_screen.dart` | 74 | Uses `FirebaseFunctions.instance` directly. |
| `lib/features/checkout/presentation/screens/checkout_screen.dart` | 76 | Calls `httpsCallable('confirmBooking')` directly. |
| `lib/features/checkout/presentation/screens/checkout_screen.dart` | 99 | Uses `FirebaseFirestore.instance` directly. |
| `lib/features/concierge/presentation/screens/concierge_screen.dart` | 127 | Uses `FirebaseFirestore.instance` directly. |
| `lib/features/concierge/presentation/screens/concierge_screen.dart` | 173 | Writes to Firestore directly. |
| `lib/features/concierge/presentation/screens/concierge_screen.dart` | 269 | Streams `concierges` directly. |
| `lib/features/concierge/presentation/screens/concierge_screen.dart` | 275 | Streams `concierge_threads` directly. |
| `lib/features/concierge/presentation/screens/concierge_screen.dart` | 281 | Streams `concierge_threads/{uid}/messages` directly. |
| `lib/features/notifications/presentation/screens/notifications_screen.dart` | 49 | Uses `FirebaseFirestore.instance` directly. |
| `lib/features/profile/presentation/screens/edit_profile_screen.dart` | 114 | Updates `users/{uid}` directly. |
| `lib/features/profile/presentation/screens/notification_settings_screen.dart` | 44 | Updates `users/{uid}` directly. |
| `lib/features/profile/presentation/screens/payment_methods_screen.dart` | 44 | Streams payment methods directly. |
| `lib/features/profile/presentation/screens/payment_methods_screen.dart` | 58 | Deletes payment method directly. |
| `lib/features/profile/presentation/screens/payment_methods_screen.dart` | 271 | Uses Firestore batch directly. |
| `lib/features/profile/presentation/screens/payment_methods_screen.dart` | 278 | Writes payment method directly. |
| `lib/features/profile/presentation/screens/security_privacy_screen.dart` | 4 | Imports `cloud_functions` in presentation. |
| `lib/features/profile/presentation/screens/security_privacy_screen.dart` | 96 | Uses `FirebaseFunctions.instance` directly. |
| `lib/features/profile/presentation/screens/security_privacy_screen.dart` | 97 | Calls `cleanupUserData` directly. |
| `lib/features/profile/presentation/screens/travel_preferences_screen.dart` | 53 | Updates `users/{uid}` directly. |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 5 | Imports `cloud_functions` in presentation. |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 26 | Uses `FirebaseFirestore.instance` directly. |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 97 | Uses `FirebaseFunctions.instance` directly. |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 98 | Calls `cancelBooking` directly. |

### 1.2 Cross-Feature Imports

Status: Fail

The spec allows imports from `core/` and controlled exposed providers, but forbids a feature from importing another feature's `data/` or `presentation/` internals directly.

| File | Line | Violation |
|---|---:|---|
| `lib/features/tour_details/presentation/screens/tour_details_screen.dart` | 12 | Imports `../../../search/data/saved_tours_repository.dart`. |
| `lib/features/search/presentation/screens/search_screen.dart` | 8 | Imports `../../../explore/data/explore_repository.dart`. |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 17 | Imports `../../../booking/data/booking_repository.dart`. |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 19 | Imports `../../../search/data/saved_tours_repository.dart`. |
| `lib/features/trips/presentation/screens/booking_confirmation_screen.dart` | 24 | Imports `../../../booking/data/booking_repository.dart`. |
| `lib/features/trips/presentation/screens/booking_confirmation_screen.dart` | 26 | Imports `../../../tour_details/data/tour_details_repository.dart`. |
| `lib/features/reviews/presentation/screens/review_trip_screen.dart` | 18 | Imports `../../../booking/data/booking_repository.dart`. |
| `lib/features/reviews/presentation/screens/review_success_screen.dart` | 11 | Imports `../../../profile/data/profile_repository.dart`. |
| `lib/features/search/data/saved_tours_repository.dart` | 4 | Imports `../../auth/presentation/controllers/auth_controller.dart`. |
| `lib/features/concierge/presentation/screens/concierge_screen.dart` | 21 | Imports `../../../profile/data/profile_repository.dart`. |
| `lib/features/profile/presentation/screens/profile_screen.dart` | 14 | Imports `../../../auth/presentation/controllers/auth_controller.dart`. |
| `lib/features/profile/presentation/screens/profile_screen.dart` | 15 | Imports `../../../booking/data/booking_repository.dart`. |
| `lib/features/profile/presentation/screens/profile_screen.dart` | 16 | Imports `../../../search/data/saved_tours_repository.dart`. |
| `lib/features/profile/presentation/screens/security_privacy_screen.dart` | 12 | Imports `../../../auth/presentation/controllers/auth_controller.dart`. |
| `lib/features/profile/presentation/screens/travel_map_screen.dart` | 9 | Imports `../../../booking/data/booking_repository.dart`. |
| `lib/features/profile/presentation/screens/travel_map_screen.dart` | 10 | Imports `../../../search/data/search_repository.dart`. |
| `lib/features/checkout/presentation/screens/checkout_screen.dart` | 22 | Imports `../../../booking/data/booking_repository.dart`. |
| `lib/features/profile/data/profile_repository.dart` | 4 | Imports `../../auth/presentation/controllers/auth_controller.dart`. |
| `lib/features/booking/presentation/screens/booking_screen.dart` | 19 | Imports `../../../tour_details/data/tour_details_repository.dart`. |

### 1.3 Files Over 250 Lines

Status: Fail

The architecture sets ~250 lines as a practical extraction trigger. These files exceed that threshold and were not split enough:

| File | Lines | Finding |
|---|---:|---|
| `lib/core/routing/app_router.dart` | 378 | Routing plus shell scaffold plus placeholder screen should be split. |
| `lib/features/auth/presentation/screens/login_register_screen.dart` | 460 | Login/register form sections should be extracted. |
| `lib/features/booking/presentation/screens/booking_screen.dart` | 865 | Calendar, participant controls, pricing, logistics, and summary should be extracted. |
| `lib/features/checkout/presentation/screens/checkout_screen.dart` | 653 | Payment methods, summary, overlay, and actions should be extracted. |
| `lib/features/concierge/presentation/screens/concierge_screen.dart` | 721 | Repository work, models, cards, chat list, and input row are all in one file. |
| `lib/features/explore/presentation/screens/explore_screen.dart` | 288 | Slightly over threshold; sections should be extracted or moved fully to widgets. |
| `lib/features/notifications/presentation/screens/notifications_screen.dart` | 289 | Grouping/list item logic should be extracted. |
| `lib/features/profile/presentation/screens/payment_methods_screen.dart` | 356 | Firestore logic and form should be separated. |
| `lib/features/profile/presentation/screens/profile_screen.dart` | 676 | Header, account overview, milestone, summary, and settings sections should be extracted. |
| `lib/features/reviews/presentation/screens/review_trip_screen.dart` | 570 | Rating, aspects, uploads, and sticky submit should be extracted. |
| `lib/features/search/presentation/screens/search_results_screen.dart` | 528 | Filter chips, cards, save controls, and map CTA should be extracted. |
| `lib/features/search/presentation/screens/search_screen.dart` | 468 | Search form, filter modal, categories, and recommendations should be extracted. |
| `lib/features/tour_details/presentation/screens/tour_details_screen.dart` | 551 | Hero, overview, itinerary, inclusions, reviews, and footer CTA should be extracted. |
| `lib/features/trips/presentation/screens/booking_confirmation_screen.dart` | 551 | Calendar/PDF/share logic and content sections should be extracted. |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 575 | Segment lists, booking cards, saved cards, and cancel logic should be extracted. |
| `lib/features/widgets_catalog_screen.dart` | 348 | Catalog/debug screen remains too large and should not ship as app surface. |

### 1.4 Use Case Folder Scope

Status: Pass with gap

`domain/usecases/` exists only in:

- `lib/features/booking/domain/usecases`
- `lib/features/reviews/domain/usecases`

No use case folder was found in forbidden features.

Gap: the spec allows `checkout/domain/usecases/` because checkout has multi-step business logic, but checkout currently has no use case layer.

### 1.5 Repository Result Handling

Status: Fail

Repository methods often return raw `Future<void>` or `Stream<T>` and can throw through providers instead of returning `Result<T>` consistently.

| File | Line | Violation |
|---|---:|---|
| `lib/features/booking/data/booking_repository.dart` | 19 | `createPendingBooking` returns `Future<void>`. |
| `lib/features/booking/data/booking_repository.dart` | 34 | `watchBooking` returns raw `Stream<Booking?>`. |
| `lib/features/booking/data/booking_repository.dart` | 52 | `watchUserBookings` returns raw `Stream<List<Booking>>`. |
| `lib/features/explore/data/explore_repository.dart` | 16 | `watchHeroPromotions` returns raw stream. |
| `lib/features/explore/data/explore_repository.dart` | 31 | `watchFeaturedTours` returns raw stream. |
| `lib/features/explore/data/explore_repository.dart` | 46 | `watchPopularDestinations` returns raw stream. |
| `lib/features/explore/data/explore_repository.dart` | 61 | `watchRecentReviews` returns raw stream. |
| `lib/features/search/data/saved_tours_repository.dart` | 17 | `watchSavedTourIds` returns raw stream. |
| `lib/features/search/data/saved_tours_repository.dart` | 27 | `saveTour` returns `Future<void>`. |
| `lib/features/search/data/saved_tours_repository.dart` | 40 | `unsaveTour` returns `Future<void>`. |
| `lib/features/search/data/saved_tours_repository.dart` | 102 | `rethrow` reaches caller after rollback. |
| `lib/features/search/data/search_repository.dart` | 74 | `searchTours` returns raw stream. |
| `lib/features/tour_details/data/tour_details_repository.dart` | 15 | `watchTour` returns raw stream. |
| `lib/features/tour_details/data/tour_details_repository.dart` | 25 | `watchReviews` returns raw stream. |

## 2. Design System Compliance

### 2.1 Raw Hex Colors in Screens

Status: Fail

| File | Line | Violation | Expected Token |
|---|---:|---|---|
| `lib/features/booking/presentation/screens/booking_screen.dart` | 570 | `Color(0xFFECF5FE)` | `AppColors.surfaceContainerLow` |
| `lib/features/booking/presentation/screens/booking_screen.dart` | 587 | `Color(0x0D002349)` | `AppShadows.cardShadow` |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 356 | `Color(0xFFE8F5E9)` | Add semantic success token or map to approved theme token. |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 357 | `Color(0xFFFFF3E0)` | Add semantic warning token or map to approved theme token. |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 364 | `Color(0xFF2E7D32)` | Add semantic success token or map to approved theme token. |
| `lib/features/trips/presentation/screens/trips_screen.dart` | 365 | `Color(0xFFE65100)` | Add semantic warning token or map to approved theme token. |

### 2.2 Direct Google Fonts Calls

Status: Pass

No direct `GoogleFonts.montserrat(...)` or `GoogleFonts.inter(...)` calls were found outside `core/theme/app_typography.dart`.

### 2.3 Screen Token Drift Against Mockups

Status: Fail

Screenshots were found at:

`C:\Users\Hafiz Muhammad Asif\Downloads\stitch_modern_travel_app_interface`

Code-level token drift found during spot-check:

| Screen | File | Line | Violation |
|---|---|---:|---|
| Explore / Home | `lib/features/explore/presentation/screens/explore_screen.dart` | 103 | Uses `BorderRadius.circular(12.0)` where premium/source card radius should be `AppRadii.lg` / 16. |
| Checkout / Payment | `lib/features/checkout/presentation/screens/checkout_screen.dart` | 268 | Uses `AppRadii.defaultRadius` for card-like payment option where premium cards should use 16. |
| Profile | `lib/features/profile/presentation/screens/profile_screen.dart` | 299 | Uses default 8px for a card-like milestone panel. |
| Concierge | `lib/features/concierge/presentation/screens/concierge_screen.dart` | 506 | Uses default 8px on the dark benefits panel; premium/dark panels should use 16. |
| Review Trip | `lib/features/reviews/presentation/screens/review_trip_screen.dart` | 248 | Uses `AppRadii.md` / 12 for tour image card where larger card treatment is expected. |

## 3. Data Model and Security Rules Compliance

### 3.1 Firestore Field Drift

Status: Fail

| File | Line | Drift |
|---|---:|---|
| `lib/features/explore/domain/tour.dart` | 21 | Uses `rating`; spec requires `ratingAverage`. |
| `lib/features/explore/domain/tour.dart` | 21 | Missing `ratingCount`. |
| `lib/features/explore/domain/tour.dart` | 25 | Adds undocumented `latitude`. |
| `lib/features/explore/domain/tour.dart` | 26 | Adds undocumented `longitude`. |
| `lib/features/explore/domain/tour.dart` | 27 | Adds undocumented `availableDates`. |
| `lib/features/explore/domain/review.dart` | 13 | Uses `rating`; spec requires `overallRating`. |
| `lib/features/reviews/domain/usecases/submit_review_use_case.dart` | 36 | Adds undocumented `bookingId` to review doc. |
| `lib/features/reviews/domain/usecases/submit_review_use_case.dart` | 37 | Writes `rating`; spec requires `overallRating`. |
| `lib/features/reviews/domain/usecases/submit_review_use_case.dart` | 38 | Writes `aspects`; spec requires `aspectRatings`. |
| `lib/features/reviews/domain/usecases/submit_review_use_case.dart` | 40 | Writes `images`; spec requires `photoUrls`. |
| `lib/features/booking/domain/booking.dart` | 39 | Adds undocumented `reviewed`. |
| `lib/features/profile/presentation/screens/payment_methods_screen.dart` | 35 | Reads `cardBrand`; spec requires `brand`. |
| `lib/core/services/notification_service.dart` | 56 | Adds `fcmToken` to `users/{uid}`; Prompt 14 requested this but §5 does not document it. |
| `lib/core/services/notification_service.dart` | 79 | Adds `deepLink` to notifications; Prompt 14 requested this but §5 does not document it. |
| `lib/features/profile/presentation/screens/notification_settings_screen.dart` | 44 | Adds `notificationPrefs`; Prompt 11 requested this but §5 does not document it. |
| `lib/features/profile/presentation/screens/travel_preferences_screen.dart` | 54 | Adds `preferences`; Prompt 11 requested this but §5 does not document it. |
| `lib/features/profile/presentation/screens/profile_screen.dart` | 524 | Reads `milesTraveled`; Prompt 11 requested this but §5 does not document it. |
| `lib/features/concierge/presentation/screens/concierge_screen.dart` | 156 | Adds `conciergeId`; Prompt 12 requested assignment but §5 does not document it. |
| `functions/src/concierge/onConciergeMessageCreated.ts` | 43 | Adds `senderType`; §5 message model only lists `senderId`, `text`, `attachmentUrl`, `createdAt`. |
| `functions/src/concierge/onConciergeMessageCreated.ts` | 25 | Adds `isTyping` on thread root; §5 defines only message docs. |

### 3.2 Firestore and Storage Rules Drift

Status: Fail

| File | Line | Drift |
|---|---:|---|
| `firestore.rules` | 62 | Allows review update/delete by review owner; spec only requires controlled authenticated review creation after completed booking. |
| `firestore.rules` | 69 | Allows clients to read/write `concierge_threads/{uid}` root, including undocumented `isTyping`. |
| `firestore.rules` | 78 | Allows users to create arbitrary notification docs; Prompt 14 intended notifications as single source of truth from service/function writes. |
| `storage.rules` | 8 | Allows public read for all `users/{uid}` storage files; prompt required authenticated user-owned writes, not public reads for all user folders. |

### 3.3 Client Writes to Function-Owned Booking Fields

Status: Pass

No client write was found to:

- `bookings/{id}.status` except initial create with `pending`
- `bookings/{id}.bookingReferenceCode`
- `bookings/{id}.stripePaymentIntentId`

Relevant evidence:

| File | Line | Evidence |
|---|---:|---|
| `lib/features/booking/presentation/screens/booking_screen.dart` | 173 | Creates booking with `status: 'pending'`. |
| `lib/features/booking/data/booking_repository.dart` | 23 | Removes `stripePaymentIntentId` before client create. |
| `lib/features/booking/data/booking_repository.dart` | 24 | Removes `bookingReferenceCode` before client create. |

## 4. Consistency and Dead Code

### 4.1 Brand Replacement

Status: Fail

| File | Line | Leftover |
|---|---:|---|
| `lib/features/auth/presentation/screens/login_register_screen.dart` | 147 | Comment still references `Horizon Elite`. |

No live UI/source string hit was found for `LuxeTravel` or `Voyage Elite` under `lib/` or `functions/src/`.

### 4.2 TODO Inventory

Status: Fail

| File | Line | Classification |
|---|---:|---|
| `functions/src/bookings/cancelBooking.ts` | 45 | Intentional placeholder: refund waits for real payment integration. |
| `lib/features/profile/presentation/screens/payment_methods_screen.dart` | 1 | Intentional placeholder, but conflicts with Prompt 11's real Stripe payment-method requirement. |
| `lib/features/search/presentation/screens/search_screen.dart` | 136 | Documented placeholder from search prompt: future settings drawer. |
| `lib/features/tour_details/presentation/screens/tour_details_screen.dart` | 510 | Undocumented shortcut: dead `See All` reviews action. |
| `lib/core/routing/app_router.dart` | 375 | Leftover placeholder text renderer. |

### 4.3 Placeholder Routes

Status: Fail

| File | Line | Violation |
|---|---:|---|
| `lib/core/routing/app_router.dart` | 150 | Top-level `/search/results` route maps to `_PlaceholderScreen`. |
| `lib/core/routing/app_router.dart` | 375 | Placeholder displays `"$title — TODO"`. |

## 5. Functional Regression Check

Status: Blocked / Fail

The full happy path could not be rerun from this environment because Flutter is not available on PATH.

Commands attempted:

```powershell
flutter analyze
flutter test
```

Both failed with:

```text
flutter : The term 'flutter' is not recognized as the name of a cmdlet, function, script file, or operable program.
```

Unverified happy path:

1. Register
2. Explore
3. Search
4. Tour details
5. Book
6. Demo checkout
7. Success
8. Trips
9. Review

## Phase-Wise Fix Plan

### Phase 0: Tooling and Baseline

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

### Phase 1: Restore Architecture Boundaries

Goal: stop presentation from owning backend access.

Tasks:

1. Move checkout `confirmBooking` callable and notification write into a checkout repository/use case.
2. Move trips booking stream and cancellation callable into a trips or booking-facing provider exposed through an allowed boundary.
3. Move concierge Firestore models, seeding, assignment, message stream, send message, and attachment metadata writes into `features/concierge/data/`.
4. Move notifications Firestore stream and read mutations into `features/notifications/data/`.
5. Move profile edit/preferences/settings/payment-method Firestore operations into `features/profile/data/`.
6. Replace presentation imports from other feature `data/`/`presentation/` with one of:
   - route navigation only,
   - promoted shared model/provider in `core/`,
   - explicitly exposed provider barrel with clear ownership.

Exit criteria:

- `rg "FirebaseFirestore|FirebaseFunctions|cloud_functions" lib/features/*/presentation` returns no hits.
- No feature imports another feature's `data/` or `presentation/` internals.

### Phase 2: Normalize Repository Error Handling

Goal: make repository boundaries consistently return `Result<T>`.

Tasks:

1. Convert write methods from `Future<void>` to `Future<Result<void>>`.
2. Decide the minimal consistent pattern for streams:
   - either `Stream<Result<T>>`, or
   - Riverpod `AsyncValue` at provider boundary with repository errors mapped before presentation.
3. Remove `rethrow` from saved-tour optimistic flow; return/emit a failure and let UI roll back.
4. Add small tests for error mapping in changed repositories.

Exit criteria:

- No repository method throws raw backend exceptions into presentation.
- Error UI still receives actionable failure messages.

### Phase 3: Data Model Alignment

Goal: make code and rules match §5 plus explicitly accepted prompt extensions.

Tasks:

1. Rename tour fields:
   - `rating` -> `ratingAverage`
   - add `ratingCount`
2. Review model/write alignment:
   - `rating` -> `overallRating`
   - `aspects` -> `aspectRatings`
   - `images` -> `photoUrls`
3. Decide whether prompt-added fields become official documented model extensions:
   - `reviewed`
   - `fcmToken`
   - `deepLink`
   - `notificationPrefs`
   - `preferences`
   - `milesTraveled`
   - `conciergeId`
   - `senderType`
   - `isTyping`
4. If accepted, update data-model docs and rules. If rejected, remove fields and adjust flows.
5. Fix payment method field:
   - `cardBrand` -> `brand`

Exit criteria:

- Seed data, models, rules, repositories, and functions use the same names.
- No undocumented Firestore fields remain unless added to the architecture doc.

### Phase 4: Security Rule Tightening

Goal: close permissive rule drift after data model decisions.

Tasks:

1. Remove or justify review update/delete access.
2. Restrict notification writes if notifications should be backend/service-owned.
3. Restrict `concierge_threads/{uid}` root writes if `isTyping` should be function-owned.
4. Revisit public storage reads under `users/{uid}/...`; split public review/profile image paths from private user uploads if needed.
5. Add emulator rule tests for:
   - own user subtree allowed,
   - other user subtree denied,
   - pending booking create allowed,
   - client booking status promotion denied,
   - review create only after completed owner booking,
   - notification write policy.

Exit criteria:

- Firestore/storage rules match the chosen model.
- Rule tests pass in emulator.

### Phase 5: Design System Cleanup

Goal: remove hardcoded visual drift with smallest safe edits.

Tasks:

1. Replace raw colors with existing tokens or add a tiny semantic success/warning token if status chips need colors not in §3.
2. Replace ad hoc radii with `AppRadii`.
3. Fix the five spot-checked radius drifts.
4. Render screenshots for:
   - auth,
   - explore,
   - search,
   - checkout,
   - profile,
   - concierge,
   - review.
5. Compare against source screenshots and record any remaining drift.

Exit criteria:

- No raw hex colors in screen files.
- Screens use design tokens instead of magic numbers where tokens exist.

### Phase 6: File Size and SRP Extraction

Goal: split large files without changing behavior.

Tasks:

1. Extract widgets from `booking_screen.dart`.
2. Extract widgets from `checkout_screen.dart`.
3. Extract widgets from `profile_screen.dart`.
4. Extract widgets from `trips_screen.dart`.
5. Extract widgets from `concierge_screen.dart`.
6. Extract widgets from `review_trip_screen.dart`.
7. Remove or isolate `widgets_catalog_screen.dart` from production routing.
8. Split router shell/placeholder helpers out of `app_router.dart`.

Exit criteria:

- No widget/screen file remains over 250 lines unless explicitly documented.
- Refactors preserve behavior and tests.

### Phase 7: Dead Code and Placeholder Removal

Goal: remove incomplete UX paths.

Tasks:

1. Replace `/search/results` placeholder route with real `SearchResultsScreen` route or remove duplicate top-level route.
2. Remove `_PlaceholderScreen` if no route uses it.
3. Implement or remove dead reviews `See All` action.
4. Remove leftover `Horizon Elite` comment.
5. Reclassify remaining TODOs as documented deferrals or fix them.

Exit criteria:

- `rg "TODO|Horizon Elite|LuxeTravel|Voyage Elite" lib functions/src` has only documented accepted deferrals.

### Phase 8: Functional Regression and Release Gate

Goal: prove the critical user path still works.

Tasks:

1. Run `flutter analyze`.
2. Run `flutter test`.
3. Run Firebase emulator tests if added.
4. Manually run:
   - register,
   - explore,
   - search,
   - tour details,
   - book,
   - demo checkout,
   - success,
   - trips,
   - review.
5. Run or repair `integration_test/critical_path_test.dart`.

Exit criteria:

- Analyzer passes.
- Tests pass.
- Happy path passes on Android.
- Any remaining external-service limitation is documented as a real blocker, not hidden as a pass.

## Suggested Fix Order

1. Phase 0
2. Phase 1
3. Phase 3
4. Phase 4
5. Phase 2
6. Phase 7
7. Phase 5
8. Phase 6
9. Phase 8

Reason: boundaries and model/rule correctness affect behavior and security; visual cleanup and extraction are safer after those contracts stop moving.
