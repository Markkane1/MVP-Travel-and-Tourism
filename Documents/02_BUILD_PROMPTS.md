# 02 — Sequential Build Prompts for the Gemini Coding Agent

Paste these one at a time, in order, after you've given Gemini the full `01_ARCHITECTURE_AND_DESIGN_SYSTEM.md` as project context. Do not start prompt *N+1* until prompt *N*'s acceptance checklist passes on a real Android device/emulator.

Each prompt assumes Gemini has read-access to the attached Stitch screenshots referenced by filename — attach the relevant PNG(s) alongside the prompt text when you send it, so Gemini can verify pixel-level layout, spacing, and imagery against your actual mockups, not just the text description here.

---

## PROMPT 1 — Environment verification & project bootstrap

```
Verify and bootstrap the Flutter project on this Windows machine. Do all of the following, in order, and report the output of each command:

1. Run `flutter doctor -v`. Confirm Flutter SDK, Android toolchain, Android Studio, and a connected Android device or running emulator are all green. If anything is missing, give me the exact Windows install/fix command — do not silently skip it.
2. Confirm Node.js LTS and npm are installed (`node -v`, `npm -v`) — required later for Firebase CLI and Cloud Functions. If missing, tell me the installer to download.
3. Create the Flutter project at the current directory with:
   - App name: mvp_travel
   - Organization/applicationId: com.mvptravelandtourism.app
   - Platforms: android, ios (both, even though we can't run iOS yet)
   - Project description: "MVP Travel and Tourism LLC — cross-platform travel and tourism booking app"
4. Immediately replace the default folder structure under `lib/` with the exact structure specified in §2 of 01_ARCHITECTURE_AND_DESIGN_SYSTEM.md. Create every folder listed there now, even empty ones (use `.gitkeep` placeholders), so the modular structure exists before any feature code is written.
5. Add every package listed in §1 of the architecture doc to `pubspec.yaml` at the latest stable version compatible with the current Flutter SDK. Run `flutter pub get` and confirm zero version conflicts. If a conflict exists, resolve it and tell me what you changed and why.
6. Set up `analysis_options.yaml` with the lint rules specified in §7 of the architecture doc.
7. Initialize git, create a `.gitignore` appropriate for Flutter + Firebase (must exclude `**/google-services.json`, `**/GoogleService-Info.plist`, `firebase_options*.dart`, `.env`, `/android/key.properties`), and make an initial commit "chore: project bootstrap and modular folder structure".
8. Create an empty `functions/` Node.js/TypeScript project per the structure in §2 (package.json, tsconfig.json, src/ folders) but do not write function logic yet — that's Prompt 9.

Acceptance checklist (confirm each explicitly):
- [ ] `flutter doctor` is clean for Android
- [ ] Project builds and runs a default counter app on an Android emulator/device with zero errors
- [ ] Folder structure under lib/ matches §2 exactly
- [ ] pubspec.yaml contains every package from §1, no extras, no substitutions
- [ ] Git repo initialized with first commit
```

---

## PROMPT 2 — Core app shell: theme, routing, shared widgets, error handling

```
Build the entire `core/` module per §2 and §3 of the architecture doc. Specifically:

1. `core/theme/app_colors.dart` — define every color token in §3.1 as a const Color, plus a fully populated Flutter `ColorScheme.light(...)` built from those exact tokens (map each design token to its corresponding ColorScheme field: primary/onPrimary/primaryContainer/onPrimaryContainer/secondary/onSecondary/secondaryContainer/onSecondaryContainer/tertiary/onTertiary/tertiaryContainer/onTertiaryContainer/error/onError/errorContainer/onErrorContainer/surface/onSurface/surfaceVariant/onSurfaceVariant/outline/outlineVariant/inverseSurface/onInverseSurface/inversePrimary/background/onBackground).
2. `core/theme/app_typography.dart` — build a `TextTheme` from the six styles in §3.2 using `google_fonts`' Montserrat and Inter, mapped onto Flutter's standard TextTheme slots (displayLarge, headlineMedium, headlineSmall, bodyLarge, bodyMedium, labelLarge as the closest matches — document your exact mapping in a code comment since Flutter's default slot names don't perfectly match the design system's names).
3. `core/theme/app_spacing.dart`, `app_radii.dart`, `app_shadows.dart` — const classes for the values in §3.3, including the two named BoxShadow levels (card shadow, modal/floating shadow).
4. `core/theme/app_theme.dart` — assemble one `ThemeData` (light only) wiring up the ColorScheme, TextTheme, and component themes for ElevatedButton, OutlinedButton, TextButton, InputDecoration (8px radius, surfaceContainer fill, navy focus border), Chip, BottomNavigationBar/NavigationBar, AppBar (transparent background, onSurface icons/text, no elevation, matching every screenshot's flat header style), Card.
5. Build every shared widget listed in §3.4 in `core/widgets/`, each in its own file, each under ~100 lines. Each widget must expose only the parameters it actually needs (no speculative "just in case" params) — this is the SRP check for this prompt.
6. `core/routing/app_router.dart` — set up `go_router` with a `StatefulShellRoute.indexedStack` for the 5 bottom-nav tabs defined in §4 (Explore, Search, Trips, Concierge, Profile), plus all the pushed (non-tab) routes listed in the screen→route table in §4, using placeholder `Scaffold(body: Center(child: Text('<RouteName> — TODO')))` screens for every route for now (real screens come in later prompts). Wire `auth_guard.dart` so any route other than `/auth` redirects to `/auth` if no Firebase user is signed in (Firebase Auth wiring itself happens in Prompt 3 — for now stub `core/services/auth_service.dart` with a fake `isSignedIn` stream you can swap later).
7. `core/utils/result.dart` — a sealed `Result<T>` type (`Success<T>` / `Failure`) used as the return type for every repository method going forward, so error handling is consistent across the whole app instead of throwing raw exceptions into the UI.
8. `core/errors/app_exception.dart` — typed exceptions: `NetworkException`, `AuthException`, `ValidationException`, `PaymentException`, `UnknownException`, each carrying a user-facing message string sourced from `app_strings.dart`.
9. `core/constants/app_strings.dart` — create the file with nested classes per feature (empty for now except an `AppStrings.common` class with: appDisplayName = "MVP Travel", retryButton = "Retry", genericError = "Something went wrong. Please try again.", noInternet = "No internet connection.").
10. Build the bottom navigation shell UI itself (icons, active/inactive states, labels: Explore/Search/Trips/Concierge/Profile) matching the navy-circle active-state treatment described in §4 — implement this as `core/widgets/app_bottom_nav.dart` consumed by the shell route.

Acceptance checklist:
- [ ] App launches showing the 5-tab bottom nav with placeholder screens, tapping each tab switches content and preserves each tab's own navigation stack (standard StatefulShellRoute behavior — verify by pushing a placeholder sub-route on one tab, switching tabs, and switching back: the sub-route should still be showing)
- [ ] Every shared widget in §3.4 renders correctly in a throwaway test screen you create temporarily and then delete
- [ ] No screen, anywhere in the app, references a raw hex color or a Google Fonts call directly — everything goes through `Theme.of(context)`
- [ ] `flutter analyze` returns zero issues
```

---

## PROMPT 3 — Firebase integration and security rules

```
Wire up Firebase for this project. I have already created the Firebase project in the console and enabled Firestore, Authentication (Email/Password, Google, Apple), Storage, Cloud Messaging, Crashlytics, and App Check, as instructed in 00_README_HOW_TO_USE.md.

1. Guide me through running `flutterfire configure` for two flavors/targets — dev and prod — generating `firebase_options_dev.dart` and `firebase_options_prod.dart` into `core/config/`. Wire `core/config/env.dart` to select the right Firebase options based on a `--dart-define=FLAVOR=dev|prod` value, defaulting to dev.
2. Implement `bootstrap.dart`: initialize Firebase with the selected options, initialize Crashlytics (catch Flutter framework errors and zone errors and forward both to Crashlytics, but only in the prod flavor — print to console in dev), initialize App Check (debug provider in dev, Play Integrity in prod for Android), then run the app inside `ProviderScope`.
3. Implement the real `core/services/auth_service.dart` wrapping `FirebaseAuth`: methods for `signInWithEmail`, `registerWithEmail`, `signInWithGoogle`, `signInWithApple`, `signOut`, `sendPasswordResetEmail`, plus an `authStateChanges` stream. Every method returns `Result<UserEntity>` (or `Result<void>`), never throws past this boundary — catch `FirebaseAuthException` and map specific error codes (`user-not-found`, `wrong-password`, `email-already-in-use`, `weak-password`, `network-request-failed`) to specific user-facing strings in `app_strings.dart`, falling back to a generic message for unmapped codes.
4. Implement `core/services/firestore_service.dart` as a thin generic wrapper (typed `get`, `set`, `update`, `delete`, `stream` methods using `withConverter` and the `freezed`/`json_serializable` fromJson/toJson of whatever model is passed in) — this file must contain zero feature-specific logic; if you find yourself adding a method like `getToursByCategory`, that belongs in the `explore` or `search` feature's repository instead, not here.
5. Implement `core/services/storage_service.dart`: `uploadImage(File, String path)` returning a download URL, with basic compression (resize to max 1600px on the longest edge before upload) to keep storage costs sane for review photos.
6. Write Firestore security rules (`firestore.rules`) implementing exactly the access policy in §5 of the architecture doc: users read/write only their own `users/{uid}` subtree and subcollections; bookings are user-scoped for read, client-creatable only in `pending` status, and only Cloud Functions (admin SDK) can transition status/payment fields; tours and reviews are public-read; reviews are writable only by the authenticated owner of a `completed` booking for that tour. Write Storage security rules (`storage.rules`) restricting uploads to authenticated users writing only to their own uid-prefixed paths, with a 10MB file size limit and image-content-type enforcement.
7. Deploy both rule sets with the Firebase CLI and confirm deployment succeeds.

Acceptance checklist:
- [ ] App boots against the dev Firebase project with no console errors
- [ ] A manual test write to `users/{myUid}` from the app succeeds; a manual test write to a different uid's document fails with a permission-denied error (verify both, don't just assume the rules work)
- [ ] Crashlytics dashboard shows a test non-fatal error after triggering one deliberately
- [ ] firestore.rules and storage.rules are committed to the repo and deployed
```

---

## PROMPT 4 — Authentication feature

```
Build the complete `features/auth` module against `luxetravel_authentication.png` (attached). 

Screen: single screen with a "Login" / "Register" segmented tab control (Login active by default, underline indicator matching the screenshot), inside a white card over the app's background. 

Login tab fields/content, top to bottom, exact copy:
- Heading wordmark "MVP Travel" where the screenshot shows "Horizon Elite" (replace brand per §6 of architecture doc)
- Label "Email Address", AppTextField with leading mail icon, placeholder "email@example.com"
- Label "Password", AppTextField with leading lock icon, obscured text, trailing show/hide toggle icon (not in the screenshot but required for usability — add it)
- Right-aligned text button "Forgot Password?" in secondary gold-ish tone matching the screenshot's amber link color (use `secondary` token)
- Full-width PrimaryButton "Sign In"
- Divider with centered label "OR CONTINUE WITH"
- Two side-by-side SecondaryButtons: "Google" and "Apple ID", each with the respective provider icon
- Footnote text, centered, smaller label style: "By continuing, you agree to MVP Travel's premium terms of use and global privacy standards." — make "terms of use" and "privacy standards" tappable text spans that, for now, push a placeholder `/legal/terms` and `/legal/privacy` route (build those as simple scrollable text placeholder screens too)

Register tab fields: Full Name, Email Address, Password, Confirm Password, a required checkbox "I agree to the Terms of Use and Privacy Policy", full-width PrimaryButton "Create Account", same social buttons and footnote below.

Behavior — be exhaustive, no shortcuts:
- Client-side validation on every field using `core/utils/validators.dart` (create email regex validator, password validator requiring 8+ chars with at least one number, confirm-password-matches validator, required-field validator, name validator). Show inline error text under each field, not a snackbar, matching the AppTextField's error slot.
- Sign In button shows a loading spinner (replace label, keep button width fixed) while the async call is in flight, and is disabled while loading to prevent double-submit.
- On successful sign-in/register, navigate to `/explore` (clearing the auth route from the stack so back button doesn't return to login).
- On failure, show the mapped error message from `AuthService` inline above the button (not a snackbar — snackbars are easy to miss on a form screen).
- "Forgot Password?" pushes a simple dedicated screen: email field + "Send Reset Link" button, calling `sendPasswordResetEmail`, showing a success confirmation state in place of the form on success.
- Google and Apple buttons call `signInWithGoogle`/`signInWithApple`. On Android, the Apple ID button must still be present and functional (Sign in with Apple works cross-platform via web flow) — do not hide it on Android.
- After this screen, if a user later opens the app with an existing Firebase session, they should land directly on `/explore` — verify `auth_guard.dart` from Prompt 2 now correctly uses the real `authStateChanges` stream instead of the stub.
- Build `AuthController` as a Riverpod `AsyncNotifier<UserEntity?>` per §2's layer rules (no domain use-case layer needed here — this is a simple feature).

Acceptance checklist:
- [ ] Visually matches luxetravel_authentication.png layout/spacing/colors (brand text replaced with "MVP Travel")
- [ ] All four validators (email, password, confirm-password, required) produce correct inline errors with real bad input
- [ ] Successful email/password registration creates a Firestore `users/{uid}` document (displayName, email, tier: "Standard", loyaltyPoints: 0, createdAt) via a Cloud Firestore write triggered right after Firebase Auth account creation
- [ ] Successful sign-in/out round-trip on a real Android device, including app restart preserving the session
- [ ] Forgot-password flow sends a real reset email (verify in your inbox)
```

---

## PROMPT 5 — Explore (Home) feature

```
Build `features/explore` against `luxetravel_home.png` (attached). This is the Explore tab's root screen.

Layout, top to bottom, exact structure:
1. App bar: search icon (left, navigates to `/search`), centered "MVP Travel" wordmark, circular profile avatar (right, navigates to `/profile`) — transparent background per theme.
2. Auto-advancing image carousel (PageView, 3 dots indicator) of promotional hero cards — each card: full-bleed background image, small uppercase eyebrow label ("LIMITED OFFER"), bold headline ("Escape to Paradise"), subtext ("Up to 40% off on overwater villas."), all left-aligned over a dark gradient scrim at the bottom of the image for legibility. Auto-advance every 5 seconds, pause on user interaction, swipeable manually.
3. A non-functional-looking but tappable search bar styled exactly like AppTextField with placeholder "Where to next?" that, on tap, navigates to `/search` (don't make it directly editable here — it's a navigation trigger, matching the screenshot's role).
4. "Categories" section header (no "See All"), horizontal scrollable row of AppChips with icons: Beach, Mountain, City, Adventure, Wellness — Beach selected by default (navy active state). Tapping a chip filters nothing on this screen but navigates to `/search/results?category=<chip>`.
5. "Featured Tours" SectionHeader with "See All" (navigates to `/search/results?featured=true`), horizontal scrollable list of tour cards: image with "FEATURED" gold badge top-left, title, subtitle ("7 Days Tour"), price right-aligned bold. Tapping a card navigates to `/tour/:tourId`.
6. "Special Offers" section: a 2-column-ish layout exactly like the screenshot — one larger dark navy card ("First Flight" / "Save $50 on your first booking" / gold "Claim" button) beside two stacked smaller cards ("FLASH DEAL 20% OFF" with a clock icon, and "Referral — Earn $100 credits" with a person-plus icon). These are promotional, non-personalized for v1 — wire "Claim" to show a simple dialog "Promo code FIRST50 applied at checkout" for now (real promo-code logic is out of scope unless you tell me to add it later).
7. "Popular Destinations" SectionHeader + "See All", horizontal scrollable destination cards: image, gold star rating badge top-right on the image ("4.9"), destination name below. Tapping navigates to `/search/results?destination=<name>`.
8. "Traveler Stories" section: list of testimonial cards (avatar, name, star rating, presumably a quote below — the screenshot is cut off here, so use a card with avatar, name, RatingStars, and a 2-line italic quote pulled from the review data model in §5; this section reads from the `reviews` collection group query, most recent 5 reviews across all tours, ordered by createdAt descending).

Data: all of Featured Tours, Special Offers, Popular Destinations, and the hero carousel content come from Firestore (`tours` collection, queried/filtered by the `badges` array field — e.g. badge contains "Featured" for Featured Tours). Build `ExploreRepository` with methods `watchHeroPromotions()`, `watchFeaturedTours()`, `watchPopularDestinations()`, `watchRecentReviews()`. Use Riverpod `StreamProvider`s per section so each section loads/errors independently — one slow or failing section must not block the rest of the page from rendering (verify this explicitly: simulate one query failing and confirm the other sections still render with their own data).

Since `tours` will be empty in a fresh Firebase project, also write a one-time Dart seed script (`tool/seed_tours.dart`, run via `dart run tool/seed_tours.dart`) that populates Firestore with at least 8 realistic sample tours covering all five categories, using royalty-free Unsplash-style image URLs, so the app is demoable immediately. Include the exact tours visible in the mockups where named ("Paris Getaway," "Serengeti Private Expedition," "Overwater Villa Experience," "Private Island Hopper," "Azure Sandbank Retreat," "Maldives Luxury Retreat," "Swiss Alpine Expedition," "Kyoto Heritage Walk") plus enough additional tours to make each horizontal list feel populated (minimum 4 items per section).

Acceptance checklist:
- [ ] Visually matches luxetravel_home.png section-by-section, including the gold/navy badge treatments
- [ ] Seed script successfully populates Firestore and the Explore screen reflects it on a fresh app install
- [ ] Each section has its own loading skeleton (not the whole screen) and independent error retry
- [ ] Pull-to-refresh re-fetches all sections
- [ ] Carousel auto-advances and is swipeable; pausing on touch works
```

---

## PROMPT 6 — Search & Filters feature

```
Build `features/search` against `luxetravel_search_results.png` and `luxetravel_search_filter.png` (both attached). This covers both the Search tab's default state and the results state.

### Search tab default state (`/search`) — from luxetravel_search_filter.png
- App bar: hamburger/menu icon left (opens nothing for now — leave a TODO, this is likely a future settings drawer, do not invent functionality for it), "Search" title, profile avatar right.
- Search bar at top: placeholder "Search tours, activities...", editable, on submit navigates to `/search/results?query=<text>`.
- "Category" row of AppChips: All (selected/navy by default), Beach, Mountain, City (+ implied more, scrollable) — selecting one immediately navigates to `/search/results?category=<chip>`.
- Two side-by-side dropdown-style selectors styled as outlined rounded buttons with a trailing chevron: "Destination" (default label "All Destinations") and "Price Range" (default label "Any Price"). Tapping either opens a bottom sheet list of selectable options (Destination: list of distinct destinations from the tours collection; Price Range: "Any Price," "Under $1,000," "$1,000–$2,500," "$2,500–$5,000," "$5,000+").
- "Popular Tours" section: vertical list of compact row cards (thumbnail, badge label like "POPULAR"/"TRENDING"/"EXCLUSIVE" in gold, title, subtitle, trailing chevron) — tapping navigates to `/tour/:tourId`.
- Bottom "Apply Filters" PrimaryButton, full-width, navigates to `/search/results` with whatever category/destination/price selections are currently set.

### Search results state (`/search/results`) — from luxetravel_search_results.png
- App bar: back arrow, destination name as title with "N Results Found" subtitle, search icon right (returns to `/search`).
- Row of removable filter chips reflecting active filters (e.g. "Beach ✕", "$2000+ ✕", "7 Days ✕") — tapping the ✕ removes that filter and re-queries; a trailing sliders/filter icon opens the same filter bottom sheet as above for adjusting further.
- Vertical scrollable list of full tour cards: large image (badge top-left: LUXURY/TOP RATED/etc in gold pill), heart/save icon top-right in a translucent dark circle (toggles `users/{uid}/savedTours/{tourId}` — must reflect saved state immediately and persist), title, metadata row ("7 Days • Max 10 people • ★ 4.9"), "From $X,XXX" price block, "View Details →" PrimaryButton (navy pill) navigating to `/tour/:tourId`.
- Floating circular map-view toggle button (bottom-right, gold) — for v1, tapping it shows a simple full-screen `google_maps_flutter` map with markers for the current result set's destinations (don't build a complex map-list sync interaction, keep it KISS: map view is read-only, tapping a marker shows a small bottom sheet with that tour's title/price/"View Details").

Data/logic:
- Build `SearchRepository` with a single flexible `searchTours({category, destination, minPrice, maxPrice, durationDays, query})` method translating to a Firestore compound query (note Firestore's limitations on compound range/array filters — if a combination isn't expressible as one query, fetch the broader set and filter client-side, and leave a code comment explaining why).
- Empty results state: use `EmptyStateView` with copy "No tours match these filters. Try adjusting your search." plus a "Clear Filters" button.
- Debounce the free-text query field by 400ms before querying.
- Saved/heart toggle must work optimistically (update UI instantly, roll back on Firestore failure) — this is the one piece of optimistic-UI behavior in v1, call it out clearly in the code with a comment since it's an exception to "just await and rebuild."

Acceptance checklist:
- [ ] Both screens visually match their mockups including the active-filter-chip pattern and the floating map toggle
- [ ] Filtering by category, destination, price range, each individually and combined, returns correct results against the seeded data from Prompt 5
- [ ] Heart/save toggle persists across app restart and is reflected on this screen, the Explore screen's cards, and the Trips → Saved segment built in Prompt 10
- [ ] Map view renders markers for the current result set and "View Details" from a marker's bottom sheet navigates correctly
```

---

## PROMPT 7 — Tour Details feature (inferred screen — no mockup provided)

```
No mockup exists for this screen in the Stitch export, but it's structurally required between Search Results ("View Details") and Booking Configuration ("Book Now"), and between Explore's "Featured Tours"/"Popular Destinations" cards and booking. Build `features/tour_details` at route `/tour/:tourId`, strictly reusing the established design tokens and component set from §3 so it feels native to the rest of the app — do not introduce any new colors, fonts, or shadow styles.

Layout:
- Full-bleed image gallery at top (PageView of `galleryImageUrls`, dot indicator), back arrow overlaid top-left in a translucent circle (matching the heart-icon treatment from search results), heart/save toggle overlaid top-right, same translucent circle style.
- Below the gallery, in a white card with `lg` radius overlapping the image slightly (consistent with the card-over-image pattern used in `luxetravel_booking_configuration.png`'s hero card): badge pill (gold), title (headlineMd), destination + rating row ("★ 4.9 · Maldives"), metadata row (duration, max participants).
- "Overview" section: body text from `tours.overview`, truncated to 4 lines with a "Read more" expand toggle.
- "Itinerary" section: vertical stepper/timeline list from `tours.itinerary` (day number in a small navy circle, title, description), collapsed to show only day 1 by default with a "View Full Itinerary" expand action, to keep the screen scannable.
- "What's Included" section: checklist-style rows (check icon + text) from `tours.inclusions`.
- "Reviews" section: SectionHeader "Reviews (N)" + "See All", horizontal scrollable review cards (avatar, name, RatingStars read-only, 2-line comment excerpt, first photo thumbnail if present) sourced from `tours/{tourId}/reviews`, most recent 5.
- Sticky bottom bar (always visible while scrolling): "From $X,XXX / person" on the left, full-width-minus-price PrimaryButton "Book Now" on the right, navigating to `/tour/:tourId/book`.

Data: `TourDetailsRepository.watchTour(tourId)` and `watchReviews(tourId)`, both `StreamProvider.family`.

Acceptance checklist:
- [ ] Screen feels visually consistent with the rest of the app (cross-check against luxetravel_search_results.png and luxetravel_home.png card styles side by side)
- [ ] Gallery, overview expand/collapse, itinerary expand/collapse, and reviews all function correctly against seeded data
- [ ] Save/heart toggle here stays in sync with the same toggle on Search Results and Explore (shared provider, not three separate states)
- [ ] "Book Now" correctly passes tourId through to Booking Configuration
```

---

## PROMPT 8 — Booking Configuration feature

```
Build `features/booking` against `luxetravel_booking_configuration.png` (attached), at route `/tour/:tourId/book`.

Layout, top to bottom, exact structure and copy:
1. App bar: back arrow, "Configure Your Trip" title, search icon right (navigates to `/search`).
2. Hero image card (16:9, rounded `lg`) of the tour with a gold "PREMIUM EXPERIENCE" badge top-left and the tour title overlaid bottom-left in white bold text over a gradient scrim — reuse the same gradient-scrim treatment from the Explore hero carousel for visual consistency.
3. "Select Tour Date" section header with calendar icon, then a white card containing: month navigation row (‹ month-year ›), day-of-week header (MO TU WE TH FR SA SU), calendar grid of selectable dates for the current month, selected date in a filled navy circle, past/unavailable dates greyed and disabled, today indicated subtly if not selected. Only dates the tour operator has availability for (model this as `tours.availableDates: array<timestamp>` — add this field to the seed data and Firestore model now) are enabled; all others are disabled/greyed even within the current month.
4. "Participants" section header with people icon, white card with two rows: "Adults" (subtitle "Ages 13 or above") with a minus/count/plus stepper starting at 1, minimum 1, maximum `tours.maxParticipants`; "Children" (subtitle "Ages 2-12") with the same stepper pattern starting at 0, minimum 0. A thin divider separates the two rows exactly as shown.
5. "Private Options" section header with shield icon, white card with: a row "Private Vehicle / Exclusive SUV & Driver" with a trailing toggle switch (off by default), and below it (visible regardless of toggle state, per the screenshot) a "Group Size Limit" label with a 3-segment control: "Shared" (selected/white by default), "Max 6", "Max 12" — selecting a non-Shared option should auto-enable the Private Vehicle toggle (a private group size implies a private vehicle; encode this dependency explicitly rather than allowing an inconsistent combination).
6. "Logistics" section header with pin icon, white card with: "Pickup Location" label + AppTextField (hotel icon leading, placeholder "Enter Hotel Name or Address"), "Special Requests" label + multiline AppTextField (placeholder "Dietary requirements, accessibility needs, etc...", 4 lines tall).
7. Sticky bottom summary bar: itemized line of plain text showing the live calculation, e.g. "$2,499 x 2 Adults + Private Vehicle" (this string must regenerate live as participants/options change, including correctly pluralizing "Adult"/"Adults" and omitting "+ Private Vehicle" when not selected), "Total" label with the bold computed price beside it, and full-width PrimaryButton "Proceed to Payment →" below.

Price calculation logic (this is the one place in this feature that earns a `domain/usecases/CalculateBookingPriceUseCase` per §2's layer rules — do not scatter this math across widgets):
```
basePrice = tour.pricePerPerson * (adults + children * 0.5)   // children at half price, document this assumption in a code comment since it's not stated in the mockup and may need a business-rule change later
groupSizeModifier = selected groupSizeOption.priceModifier (0 for Shared)
privateVehicleSurcharge = tour.privateVehicleSurcharge if toggle is on, else 0
total = basePrice + groupSizeModifier + privateVehicleSurcharge
```
Use case must be unit-tested with at least 5 cases (shared/no extras, private vehicle only, max-6 group, max-12 group, with children) confirming exact totals.

Validation: "Proceed to Payment" is disabled until a date is selected and pickup location is non-empty; show inline guidance (not a blocking dialog) for what's missing if the user tries to tap while disabled — actually keep the button enabled but show a single-line warning above it listing missing fields when tapped while incomplete, since a disabled button with no explanation is a usability dead-end.

On submit: create a Firestore `bookings/{bookingId}` document in `pending` status with all configured fields (per the data model in §5) via `BookingRepository.createPendingBooking(...)`, then navigate to `/booking/:bookingId/checkout`.

Acceptance checklist:
- [ ] Matches mockup pixel-for-pixel on layout/spacing/copy, including the live price-summary string format
- [ ] Calendar correctly disables unavailable/past dates using seeded `availableDates`
- [ ] Selecting Max 6 or Max 12 auto-toggles Private Vehicle on; manually toggling Private Vehicle off while a Max option is selected should NOT silently revert the group size — instead show a brief inline note that private vehicle is required for non-shared groups and keep the toggle on (avoid a confusing UI fight between two controls)
- [ ] CalculateBookingPriceUseCase unit tests all pass
- [ ] Submitting creates a correctly-shaped pending booking document in Firestore
```

---

## PROMPT 9 — Checkout & Payment feature (Stripe + Apple Pay + Google Pay) + Cloud Functions

```
This is the most sensitive feature in the app — it moves real money. Build `features/checkout` against `luxetravel_payment.png` (the canonical version per §4.1 — attached), plus `luxetravel_payment_processing.png` and `luxetravel_payment_success.png` (both attached), at routes `/booking/:bookingId/checkout`, processing overlay, and `/booking/:bookingId/success`.

### Server side first (functions/src/stripe/)
1. `createPaymentIntent.ts` — a callable Cloud Function taking `{ bookingId }`, reading the booking from Firestore (admin SDK, bypasses client rules), verifying it belongs to the calling user and is still `pending`, creating (or reusing, if the user has a `stripeCustomerId`) a Stripe Customer, creating a Stripe PaymentIntent for `booking.totalPrice` in `booking.currency`, with `automatic_payment_methods.enabled = true` (this is what makes Apple Pay/Google Pay available automatically in the PaymentSheet without separate wiring), storing `stripePaymentIntentId` on the booking, and returning the PaymentIntent's `client_secret`, the Stripe `ephemeralKey` secret, and the `customerId` to the client (these three values are exactly what `flutter_stripe`'s `PaymentSheet.initPaymentSheet` requires).
2. `stripeWebhook.ts` — an HTTPS function registered as the Stripe webhook endpoint, verifying the Stripe signature, handling `payment_intent.succeeded` by transactionally updating the booking to `status: confirmed`, generating `bookingReferenceCode` (pattern: "LT-" + 5 random digits + "-" + first 3 letters of category uppercased, e.g. "LT-58291-EXP"), incrementing the user's `loyaltyPoints` by `floor(totalPrice / 10)`, and writing a `notifications/{uid}/items` document ("Booking Confirmed — your expedition is ready"); handling `payment_intent.payment_failed` by updating the booking to `status: cancelled` with a failure reason field.
3. `refundPayment.ts` — callable function for the cancel-booking flow built in Prompt 10 (build the function now, wire the client call later).
4. Set Stripe secret key via `firebase functions:secrets:set STRIPE_SECRET_KEY` (walk me through this command) — never put it in code or in any committed file. Deploy functions and confirm the webhook URL, then walk me through registering that URL in the Stripe dashboard's webhook settings.

### Client side (features/checkout/)
1. Initialize `flutter_stripe` with the Stripe **publishable** key from `core/config/env.dart` (different per dev/prod flavor) in `bootstrap.dart`.
2. Checkout screen layout, top to bottom: app bar "Checkout" + lock icon right (static, just a trust signal, not interactive); order summary card (tour image thumbnail, title, date, participant count, private-vehicle indicator if applicable, "Total Price" with bold amount); side-by-side "Apple Pay"/"Google Pay" quick-pay buttons (use Stripe's PaymentSheet — these two buttons both trigger the same `presentPaymentSheet()` call, the SheetUI itself decides what to show per-platform, so implement them as one shared handler, not duplicated logic); divider "OR PAY WITH CARD"; a "Credit or Debit Card" white card containing Cardholder Name field, Card Number field (use Stripe's `CardField` widget, do not hand-roll card input or touch raw PANs anywhere in app code — this is a hard requirement, not a style preference, for PCI compliance), Expiry/CVV (these come bundled inside Stripe's `CardField`, don't build separate fields if `CardField` already renders them — match the visual layout via `CardField`'s styling options instead of fighting it with custom widgets), a "Save card details for future bookings" checkbox; a "Bank Transfer — Direct wire from your bank account" row with trailing chevron (for v1, tapping this shows a simple instructions screen with your company's bank details as static text — no live integration); trust footnote "Secure 256-bit SSL Checkout — Your payment information is encrypted and never stored on our servers."; sticky bottom PrimaryButton "Pay $X,XXX →" reflecting the live booking total.
3. On any pay action (Apple Pay, Google Pay, or the bottom Pay button after filling the CardField): call `createPaymentIntent` Cloud Function, then `Stripe.instance.initPaymentSheet(...)` with the returned client secret/ephemeral key/customer id, then `Stripe.instance.presentPaymentSheet()`. While this is in flight, show the processing overlay from `luxetravel_payment_processing.png`: the existing checkout screen visually blurred/dimmed behind a centered circular badge with a "PROCESSING…" label and lock icon, plus "Processing Payment..." text below it — implement the blur with a `BackdropFilter`, and the circular badge as a looping rotation animation, matching the screenshot's ornamental ring design as closely as practical with a custom-painted or SVG-based circular motif (don't worry about replicating the exact decorative pattern stroke-for-stroke — match the navy/gold color treatment and the rotating-ring motion).
4. On success (PaymentSheet returns success): navigate to `/booking/:bookingId/success`, showing the success screen exactly per `luxetravel_payment_success.png`: centered navy circle check icon, "Payment Successful" headline, body text "Your expedition is now confirmed. A digital receipt has been sent to your email.", a light card showing "BOOKING ID:" + the `bookingReferenceCode` (poll/stream the booking document briefly here since the webhook writes the reference code asynchronously after the PaymentSheet confirms — show a brief inline loading state on that one line if it hasn't arrived within ~1 second, do not block the whole success screen on it), sticky bottom PrimaryButton "View Your Itinerary →" navigating to `/trips/:bookingId`.
5. On failure or user cancellation of the PaymentSheet: stay on the checkout screen, dismiss the processing overlay, show an inline error banner ("Payment failed. Please check your details and try again." or the specific Stripe error message if safe to show), do not navigate away, do not leave the booking in a half-updated state (it should still read `pending`).

Acceptance checklist:
- [ ] A real test-mode payment (Stripe test card 4242 4242 4242 4242) completes end-to-end: PaymentIntent created, PaymentSheet shown, payment confirmed, webhook fires, booking flips to confirmed with a generated reference code, loyalty points increment, notification document created
- [ ] Google Pay button works on a real Android device with a test card configured in the device's Google Pay (Apple Pay button is present and code-complete but cannot be tested until iOS hardware exists — confirm this explicitly rather than silently skipping it)
- [ ] A deliberately failed test card (4000 0000 0000 0002, "card declined") produces the correct inline failure state without navigating away or corrupting booking state
- [ ] No raw card number ever touches a Dart variable, log statement, or Firestore document anywhere in the codebase — grep for this explicitly and show me the grep came back clean
- [ ] Processing overlay visually matches the screenshot's blur/dim/centered-badge composition
```

---

## PROMPT 10 — Booking Confirmation & Trips feature

```
Build `features/trips` against `luxetravel_booking_confirmation.png` and `luxetravel_profile_dashboard.png` (both attached). This covers the post-purchase confirmation screen and the Trips bottom-nav tab (which, per §4, absorbs the corrupted "saved_tours" and "profile_history" screens as segments).

### Booking Confirmation screen — `/trips/:bookingId`, from luxetravel_booking_confirmation.png
- App bar: "MVP Travel" wordmark centered (brand replaced per §6), avatar right.
- Centered navy circle check icon, "Booking Confirmed" headline, "Your expedition is secured and ready for departure." subtext.
- White card: tour hero image, gold "CONFIRMED EXPERIENCE" badge, title, date row (calendar icon + date), participants row (people icon + count), private-vehicle row (car icon, only if applicable), bookingReferenceCode displayed with a ticket icon.
- "Logistics" white card: pin icon + "PICKUP LOCATION" label + the address text the user entered during booking configuration (not static — must reflect the real `pickupLocation` field).
- Static map preview (`google_maps_flutter` with interaction disabled, or a `GoogleMap` snapshot-style widget) showing the pickup location's approximate coordinates (geocode the address string at booking-confirmation time via the Geocoding API if available, otherwise fall back to the tour's destination's known coordinates stored in the seed data — implement the fallback so the screen never shows a broken/empty map), with a "View in Maps" pill button that opens the native maps app via a `geo:` / Apple Maps URL using `url_launcher`.
- Dark navy "What's Next" card with 3 numbered steps exactly as in the screenshot: "1 — Confirmation Details: Check your email for full itinerary and digital tickets.", "2 — Concierge Outreach: A travel concierge will reach out within 24 hours to customize your gear.", "3 — Prepare for Adventure: Review the luxury safari packing guide in your profile." (keep this copy generic/templated per tour category rather than literally hardcoded to "safari" for every booking — parametrize step 3's text based on `tour.category`, e.g. "Review the [category] preparation guide in your profile.")
- "Add to Calendar" gold outlined button using `add_2_calendar` with the tour's date/title/pickup location.
- "Download PDF Receipt" outlined button generating a simple one-page PDF (`pdf` package) with booking details and your company's name/address as letterhead, then sharing it via `printing`'s share sheet.
- "Back to Home" PrimaryButton navigating to `/explore`.

### Trips tab — `/trips`, from luxetravel_profile_dashboard.png's booking-list portion
- App bar: "MVP Travel" wordmark, avatar right.
- 3-segment control: "Upcoming Bookings" (default), "History", "Saved Tours".
- **Upcoming Bookings** segment: vertical list of booking cards (image, title, status pill — "CONFIRMED" green or "PENDING" amber, date range, "View Details →" text link navigating to `/trips/:bookingId`, "Cancel Booking" red text link) for bookings with `status in [pending, confirmed]` and `tourDate >= now`, ordered soonest-first. Cancel flow: confirmation dialog ("Cancel this booking? This may be subject to the tour's cancellation policy.") → on confirm, call the `refundPayment` Cloud Function built in Prompt 9 if `stripePaymentIntentId` exists, then update booking `status: cancelled`.
- **History** segment: same card style for bookings with `status == completed or (status == confirmed and tourDate < now)`, with "View Details →" and, if no review exists yet for that booking, a "Leave a Review" gold text link navigating to `/trips/:bookingId/review` (Prompt 13); if a review already exists, show "★ Reviewed" instead, non-interactive.
- **Saved Tours** segment: grid or list of the user's `savedTours` (reuse the same save/heart provider from Search/Tour Details — do not build a second saved-state source of truth), each item navigating to `/tour/:tourId`, with the heart icon visible and toggleable here too (un-saving from this screen removes it from the list with a brief undo snackbar).
- "New Adventure?" dashed-border empty/prompt card at the bottom of the Upcoming segment specifically when that segment is empty, exactly as shown ("Your next world-class experience is just a click away." + "Explore Tours" button to `/explore`) — for History and Saved, use the standard `EmptyStateView` instead with segment-appropriate copy.

Acceptance checklist:
- [ ] Confirmation screen correctly reflects the real booking just completed in Prompt 9's end-to-end test, including the geocoded/fallback map and correct category-parametrized step-3 copy
- [ ] Add to Calendar and Download PDF Receipt both produce correct, real output on device
- [ ] Trips tab's three segments correctly bucket a mix of pending/confirmed/completed/cancelled test bookings (manually create a few via the Firestore console with different statuses/dates to verify bucketing logic, don't only test with one happy-path booking)
- [ ] Cancel booking flow updates Firestore and, when a payment intent exists, successfully triggers a Stripe test refund (verify in the Stripe dashboard)
- [ ] Saved Tours segment stays in sync with the heart toggle everywhere else in the app
```

---

## PROMPT 11 — Profile & Account feature

```
Build `features/profile` against `luxetravel_user_profile.png` (attached), at route `/profile` (tab 5).

Layout, top to bottom, exact structure:
1. App bar: "MVP Travel" wordmark, notification bell icon right (navigates to `/notifications`, Prompt 14).
2. Profile header: circular avatar (tap to view full image, long-press/tap an edit pencil overlay to navigate to `/profile/edit`), small badge icon overlapping the avatar's bottom-right corner indicating verified/elite status, name (headlineMd), an amber "Elite Member" pill, and "N Loyalty Points" text — all sourced live from `users/{uid}`.
3. Outlined "Edit Profile" pill button navigating to `/profile/edit` (build this as a simple form screen: avatar with "Change Photo" using `image_picker` + `storage_service` upload, Full Name field, Email field shown read-only with a note "Contact support to change your email", Save button updating Firestore and, for name, also updating the Firebase Auth display name).
4. Dark navy "CURRENT TIER" card: tier name in gold ("Elite Horizon Status" — pull from `users.tier`), small medal icon top-right, then 4 rows of tier benefits with icons (24/7 Personal Concierge, Private Lounge Access, Priority Boarding, Complimentary Upgrades) — for v1 these benefit rows are static copy per tier (define a simple `Map<String, List<String>>` of tier → benefit list with at least "Standard" and "Elite Horizon" entries, don't hardcode only the one tier shown in the mockup).
5. "Next Milestone" card: "N points to [Next Tier]" text, a progress bar, percentage label, "View All Benefits" outlined button (pushes a simple static info screen listing all tiers and their thresholds/benefits).
6. "Account Overview" section: 4 tappable rows, each icon + title + dynamic subtitle + chevron — "My Trips" ("N upcoming bookings", live count, navigates to `/trips`), "Saved Destinations" ("N items in wishlist", live count, navigates to `/trips` with the Saved segment pre-selected), "Payment Methods" ("Visa ending in •••• NNNN" from the user's default saved Stripe payment method, or "No payment method saved" if none, navigates to `/profile/payment-methods`), "Travel Preferences" (static subtitle for v1, navigates to a simple preferences form: dietary requirements, seating preference, preferred hotel class — persisted to a new `users.preferences` map field).
7. "Travel Summary" white card: three stat rows (Destinations Visited, Miles Traveled, Active Bookings) computed live — Destinations Visited = count of distinct `tour.destination` across the user's completed bookings; Active Bookings = count of pending+confirmed bookings; Miles Traveled is not derivable from current data, so for v1 store it as a simple `users.milesTraveled` number field defaulting to 0 and document clearly in code that this needs a real computation source later (e.g. distance between home location and each destination) rather than faking a formula now. Below the stats, an "Explore Travel Map" banner button (static image banner is acceptable for v1, or reuse the same world-map style treatment) navigating to a simple full-screen map showing pins for all destinations visited.
8. "Settings & Support" section: 4 rows — "Security & Privacy" (navigates to a screen with: Change Password, the App Check/biometric-lock toggle if you choose to add one, and a "Delete Account" destructive action with a confirmation flow that actually deletes the Firebase Auth user and triggers a Cloud Function to clean up their Firestore data), "Notification Settings" (toggles for booking updates, promotions, concierge messages, persisted to `users.notificationPrefs`), "Help Center & Support" (a simple FAQ/contact screen — static content, a mailto: link to a support email, and a link to `/legal/terms`/`/legal/privacy` reused from Prompt 4), "Logout" in red, with a confirmation dialog, calling `AuthService.signOut()` and routing back to `/auth`.

Payment Methods sub-screen (`/profile/payment-methods`): lists saved Stripe payment methods (`users/{uid}/paymentMethods`, populated by a Cloud Function listener whenever Stripe attaches a payment method to the customer during a "save card" checkout), each as a card-brand icon + masked number + "Default" tag if applicable + a remove (X) action calling a `detachPaymentMethod` callable function; "Add Payment Method" button opens Stripe's `CardField` in a bottom sheet and calls a `createSetupIntent` callable function to save it without an active charge.

Acceptance checklist:
- [ ] Matches mockup layout/copy/colors, with all listed dynamic values genuinely live from Firestore/Auth (not hardcoded placeholders left in)
- [ ] Edit Profile successfully updates both Firestore and Firebase Auth display name, and photo upload round-trips correctly
- [ ] Account Overview row counts are correct against your test data
- [ ] Payment Methods screen correctly lists, sets default, and removes a real Stripe test payment method
- [ ] Logout clears session and returns to `/auth`; relaunching the app does not silently re-authenticate
```

---

## PROMPT 12 — Travel Concierge feature

```
Build `features/concierge` against `luxetravel_travel_concierge.png` (attached), at route `/concierge` (tab 4).

Layout, top to bottom:
1. App bar: "MVP Travel" wordmark, notification bell right (shared with Profile's bell, same route).
2. Headline "Travel Concierge" (headlineLg) + subtext "Your personal assistant is ready to craft your next experience."
3. Assigned concierge card: avatar photo, name + role ("Elena, Senior Travel Specialist"), small green online-status dot, "Expert in [specialty]" and "[languages]" rows with icons, full-width "Contact Elena" PrimaryButton (for v1, since there's no real human-staffing backend, tapping this scrolls/navigates straight to the chat input at the bottom of this same screen rather than implying a phone call — be explicit in the UI copy that this opens chat, don't imply a feature that doesn't exist). Source the assigned concierge from a simple `concierges` Firestore collection seeded with at least 2 sample profiles, assigned to a user round-robin or by a simple `concierges` doc reference on the user's profile — don't over-engineer matching logic for v1.
4. Dark navy "Elite Benefits" card: two benefit rows with icons (24/7 Priority Support, Tailored Experiences) — static copy matching the screenshot.
5. "How can we help?" section: 4 tappable cards, each icon + title + subtitle + chevron — "Book a Private Jet", "Restaurant Reservations", "Custom Itinerary", "Emergency Assistance". For v1, each of these pre-fills the chat input at the bottom with a relevant starter message (e.g. tapping "Book a Private Jet" scrolls to the input and pre-fills "I'd like to book a private jet for..." for the user to complete and send) rather than opening separate unbuilt flows — be explicit that this is the v1 behavior.
6. Chat area: this screen is itself the chat (not a separate thread list — single concierge per user for v1). Below the static content above, render the live message thread (`concierge_threads/{uid}/messages`, ordered by createdAt, real-time `StreamProvider`) as a standard chat list: user messages right-aligned navy bubbles, concierge messages left-aligned with avatar and grey bubbles. Show a typing indicator row ("Elena is typing...") when applicable — for v1 without a real human backend, simulate this: after the user sends a message, show the typing indicator for 1.5–3 seconds, then auto-post a canned acknowledgment reply from the concierge ("Thanks for reaching out! I'll have a tailored option ready for you within 24 hours.") via a Cloud Function trigger (`onConciergeMessageCreated`) — implement this server-side, not client-side, so it behaves correctly even if the app is backgrounded, and document clearly in code comments that this is a placeholder for real human/AI concierge staffing later.
7. Input row: paperclip attachment icon (opens `image_picker`, uploads via `storage_service`, sends as a message with `attachmentUrl` set), text field placeholder "Type a message...", navy circular send button.

Acceptance checklist:
- [ ] Matches mockup layout/copy
- [ ] Sending a message persists it to Firestore and appears instantly (optimistic local echo is acceptable here, document it as the second sanctioned exception to "always await" alongside the saved-tours heart toggle from Prompt 6)
- [ ] Cloud Function auto-reply fires correctly and the typing indicator timing feels natural, not jarring
- [ ] Attachment upload/send works end-to-end on a real device
- [ ] "How can we help?" quick-action cards correctly pre-fill and focus the chat input
```

---

## PROMPT 13 — Reviews feature

```
Build `features/reviews` against `luxetravel_review_trip.png` (use this version — `_refined_review_trip.png` is the same screen per §4.1, build once) and `luxetravel_review_success.png` (both attached), at routes `/trips/:bookingId/review` and `/trips/:bookingId/review/success`.

### Review form screen
- App bar: back arrow, "Review Trip" title, vertical-three-dot overflow menu right (for v1, its only action is "Cancel Review" which discards and pops back — don't leave a dead-end menu with no action).
- White card: tour thumbnail, title, date range, sourced from the booking being reviewed.
- "How was your experience?" centered label + 5 interactive stars (use the `RatingStars` shared widget's input variant from §3.4), unrated state shown as outlined stars per the screenshot.
- "RATE SPECIFIC ASPECTS" small caps label, 2x2 grid of selectable cards (Service, Accommodation, Activities, Value), each with an icon — tapping one opens a small inline 5-star selector for that specific aspect (the screenshot shows them as static icon buttons; since the data model in §5 requires per-aspect numeric ratings, implement tapping a card as expanding it in place to reveal its own 5-star row, collapsing the others, so all 4 aspect ratings are actually collected before submit is enabled).
- "Share your thoughts" label + multiline AppTextField (placeholder "Tell us about your highlight moments...", ~6 lines tall).
- "Share your memories" label + "Up to 6 photos" subtext, horizontal row: a dashed-border "Upload" tile (image icon + "Upload" label) followed by however many photos have been added as thumbnails (each with a small remove ✕ overlay), using `image_picker` (multi-select where the platform supports it) and uploading through `storage_service` with a visible per-photo upload progress indicator, capped at 6 — disable/hide the Upload tile once 6 are reached.
- Sticky bottom full-width PrimaryButton "Submit Review →", disabled until the overall star rating is set (all 4 aspect ratings and the comment are encouraged but not required to enable submit — only the overall rating is mandatory, matching how the screenshot visually emphasizes the top 5-star row over everything else).

Submission (this earns a `domain/usecases/SubmitReviewUseCase` per §2's layer rules, since it's a genuinely sequenced multi-step operation): write the review document to `tours/{tourId}/reviews`, which triggers the `onReviewSubmitted` Cloud Function (build this now in `functions/src/reviews/`) that increments the user's `loyaltyPoints` by a fixed 250 and returns/writes the new balance, then update the corresponding `bookings/{bookingId}` with a `reviewed: true` flag so the Trips → History segment stops offering "Leave a Review" for it. Navigate to the success screen only after the Firestore write resolves (not optimistically — getting loyalty points wrong by showing a number before it's confirmed would be a real user-trust problem, unlike the cosmetic heart-toggle/chat-echo exceptions earlier).

### Review success screen
- Centered circular image (a relevant celebratory photo or simple icon treatment — the mockup shows a toast/celebration photo with a checkmark overlay; for v1 use a simple gold checkmark-in-circle treatment consistent with the rest of the app's icon language rather than sourcing a stock photo, since stock photo selection isn't something to leave ambiguous) — actually for fidelity to the screenshot, use the tour's own hero image here with a gold checkmark badge overlaid bottom-right, which is both achievable and consistent.
- Headline "Thank You, [FirstName]" (pull first name from `users.displayName`).
- Body text "Your review of [Tour Title] has been shared. Your insights help us maintain the world-class standards of MVP Travel." (brand replaced per §6, was "Voyage Elite" in the source).
- White card: star icon, "POINTS EARNED" label, "+250 pts" in gold large text, divider, "New Balance: N pts" (the real updated balance, re-read from Firestore after the Cloud Function completes — show a brief loading state on just this line if needed, same pattern as the booking reference code in Prompt 9).
- Light pill banner "Your photos have been added to the tour gallery." (only shown if at least one photo was uploaded).
- "Back to Dashboard" PrimaryButton → `/trips`. Outlined "Explore New Destinations" button → `/explore`.

Acceptance checklist:
- [ ] Full review submission round-trip works: rating + aspects + comment + 2 test photos submit correctly, loyalty points increment by exactly 250, booking flips `reviewed: true`
- [ ] Submit button correctly stays disabled until overall rating is set, and correctly enables the moment it is, with no other field required
- [ ] Photo cap of 6 is enforced with clear UI feedback when reached
- [ ] History segment in Trips no longer offers "Leave a Review" for this booking after submission
```

---

## PROMPT 14 — Notifications feature

```
Build `features/notifications` at route `/notifications`, reached from the bell icon on Profile and Travel Concierge app bars (no dedicated mockup exists for this — keep it simple and visually consistent with the rest of the app, reusing AppCard and the established spacing/typography, per the same rule as Prompt 7).

1. Wire `firebase_messaging`: request notification permission on first app launch (after auth, not before — don't prompt before the user has any reason to expect notifications), store the FCM token on `users/{uid}.fcmToken`, handle foreground messages by also writing them into the `notifications/{uid}/items` Firestore collection so the in-app list and push notifications stay consistent (a single Cloud Function, `sendPushOnNotificationCreated`, triggers on every new `notifications/{uid}/items` write and sends the corresponding FCM push — this means all other features that create notifications, like the Stripe webhook and the review/booking flows, only ever need to write to Firestore, never call FCM directly; keep push-sending centralized in this one function for SRP).
2. Notifications list screen: app bar "Notifications" + back arrow, a "Mark all read" text action top-right, vertical list grouped loosely by recency (Today / Earlier — simple date-based grouping, not a calendar widget), each row: leading icon varying by `type` (booking/promo/concierge/system, map each to an appropriate Material Symbol), title, body (2-line max, ellipsized), relative timestamp ("2h ago"), unread items shown with a subtle navy dot and a tinted background per the `surfaceContainerLow` token; tapping a row marks it read and, where applicable, deep-links to the relevant screen (a booking notification → `/trips/:bookingId`, a concierge notification → `/concierge`, encode this via a `deepLink` string field on the notification document set by whichever Cloud Function created it).
3. Empty state: standard `EmptyStateView`, "No notifications yet."
4. Badge count: the bell icon itself shows a small red dot (not a number, per the design system's minimal aesthetic — don't introduce a numeric badge style that doesn't exist anywhere else in the app) when any unread notification exists, computed from a live Firestore count query.

Acceptance checklist:
- [ ] A real push notification arrives on a physical/emulated Android device after triggering one of the existing Cloud Functions that writes a notification (e.g. complete another test booking)
- [ ] In-app list and the push notification content match exactly (single source of truth, no drift)
- [ ] Mark-all-read and individual tap-to-read both work and persist
- [ ] Deep links from booking/concierge notifications land on the correct screen with correct data
```

---

## PROMPT 15 — Testing, accessibility, app icon/splash, Android release readiness, iOS readiness checklist

```
Close out the v1 build with the following, in order:

### Testing
1. Add unit tests for every `domain/usecases/` class (CalculateBookingPriceUseCase, SubmitReviewUseCase) and every repository's pure mapping/parsing logic (Firestore document → model), using `mocktail` to fake Firestore/Auth/Stripe calls — target realistic coverage of business logic, not a vanity percentage on generated boilerplate.
2. Add widget tests for the 5 shared components most reused across the app (PrimaryButton, AppTextField, AppCard, AppChip, RatingStars) covering their distinct states (loading/disabled/error where applicable).
3. Add one `golden_toolkit` golden test per bottom-nav tab's root screen (Explore, Search, Trips, Concierge, Profile) at a standard Android phone size, to catch unintended visual regressions as the app evolves.
4. Add one `integration_test` covering the critical path end-to-end against the dev Firebase project with Stripe test mode: register → land on Explore → search → tour details → book → checkout with test card → success → appears in Trips → leave a review → loyalty points increment. This is the single most valuable test in the suite — give it real attention, not a token stub.

### Accessibility pass
5. Verify every interactive element has a minimum 48x48dp tap target (Flutter's default Material widgets mostly handle this, but check custom widgets like the heart-toggle overlay icons and the star rating input specifically).
6. Add `Semantics` labels to icon-only buttons (heart/save, back arrow, search icon, notification bell, calendar nav arrows, payment method remove ✕) so screen readers announce their purpose, not just "button."
7. Confirm text scaling: test the app at the system's largest accessibility font size setting and fix any overflow you find — report which screens needed fixes.
8. Confirm color contrast of body text on every background color combination used (the navy-on-light and white-on-navy combinations from the design tokens should already pass WCAG AA at the font sizes specified — verify and report rather than assume).

### App icon, splash screen, branding polish
9. Generate an app icon set (`flutter_launcher_icons`) from a simple icon design consistent with the navy/gold brand palette (a compass or wave motif fits "MVP Travel" — propose 2 simple options as SVG/description before generating final assets, don't pick unilaterally for something this visible).
10. Generate a native splash screen (`flutter_native_splash`) using the `background` surface color (#F6FAFF) and the same icon mark, matching the calm/airy brand tone.

### Android release readiness
11. Configure `android/app/build.gradle` product flavors for dev/prod matching the `--dart-define=FLAVOR` approach from Prompt 3, each with distinct `applicationIdSuffix` so dev and prod can be installed side-by-side on the same device for testing.
12. Set up release signing: generate a keystore, create `android/key.properties` (already gitignored per Prompt 1), wire it into `build.gradle`, and produce a release `.aab` build, confirming `flutter build appbundle --flavor prod` succeeds.
13. Fill out a checklist of remaining Play Store listing requirements (privacy policy URL — point it at the `/legal/privacy` content from Prompt 4 hosted as a real public page, not just an in-app screen; data safety form, since this app collects auth/payment/location data; content rating questionnaire) and tell me which of these need my direct action outside of code.

### iOS readiness checklist (code/config only — no Mac required yet, nothing here should be skipped just because it can't be fully tested today)
14. Confirm `ios/Runner/Info.plist` has correct permission usage strings (camera/photo library for review photos and profile photo, location for the map features, push notification entitlement) with clear, honest descriptions of why each permission is needed.
15. Add the Apple Pay merchant entitlement file (`ios/Runner/Runner.entitlements`) with a placeholder merchant ID clearly marked `TODO: replace with real Apple Merchant ID once Apple Developer account is set up`.
16. Add the Sign in with Apple capability entry to the entitlements file.
17. Produce a short written handoff doc, `IOS_HANDOFF.md`, listing every action that requires the physical Mac/Xcode later: opening the project in Xcode to set the development team/signing, enabling the Apple Pay and Sign in with Apple capabilities in Xcode's capability UI (the entitlements file alone isn't sufficient, Xcode must register them against your Apple Developer account), running on a real iOS device or simulator for the first time, archiving and uploading to TestFlight/App Store Connect. This doc is your starting checklist the day you get iOS hardware — it should require no further code changes, only Xcode configuration and store submission.

Acceptance checklist:
- [ ] Full test suite passes (`flutter test`) and the integration test passes against a real (test-mode) backend
- [ ] Accessibility fixes applied and reported per screen
- [ ] App icon and splash screen render correctly on a real device install
- [ ] `flutter build appbundle --flavor prod` succeeds and produces an installable, correctly-signed release build
- [ ] IOS_HANDOFF.md exists and is a complete, accurate list with nothing deferred silently
```
