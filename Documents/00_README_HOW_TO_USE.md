# MVP Travel and Tourism LLC — Flutter App Build Kit

This kit contains everything needed to direct a Gemini coding agent to build the app end‑to‑end, in order, with nothing left to its own judgment on architecture, design tokens, copy text, or data shape.

## Files in this kit

1. **00_README_HOW_TO_USE.md** — this file.
2. **01_ARCHITECTURE_AND_DESIGN_SYSTEM.md** — the locked technical spec: stack, folder structure, design tokens, data model, canonical navigation. Give this to Gemini once, at the start, as permanent project context.
3. **02_BUILD_PROMPTS.md** — 15 sequential, numbered prompts. Paste one at a time, in order, into the Gemini coding agent. Each prompt is self-contained and ends with an acceptance checklist — do not move to the next prompt until the current one's checklist passes.

## Decisions already locked in (so you don't get asked mid-build)

- **Backend:** Firebase (Firestore, Firebase Auth, Firebase Storage, Cloud Functions, Cloud Messaging, Crashlytics, Analytics, App Check).
- **State management:** Riverpod (`flutter_riverpod` + `riverpod_generator`/`riverpod_annotation`). Chosen because it gives you compile-time-safe DI without a second framework (no need for `get_it`), it scales cleanly across feature modules, and it has first-class testing support — all of which matter for a modular, multi-feature app built incrementally by an AI agent across many sessions.
- **Payments:** Stripe via `flutter_stripe`'s PaymentSheet, which natively supports Apple Pay and Google Pay in one integration (this is the current recommended approach over wiring Apple Pay / Google Pay SDKs separately). A Cloud Functions backend is mandatory for this — your Stripe **secret key** must never live in the Flutter app, only in Cloud Functions.
- **Brand name conflict resolved:** Your Stitch export uses three different names across screens/files ("Horizon Elite," "LuxeTravel," "Voyage Elite"). All of these are replaced everywhere with your real company branding:
  - Legal entity (footers, terms, invoices, store listing "company name"): **MVP Travel and Tourism LLC**
  - In-app display name / app bar wordmark / app icon label: **MVP Travel**
  - If you want a different short name, tell Gemini to find-and-replace `MVP Travel` — every prompt uses that one token consistently so it's a single search-and-replace.
- **Navigation conflict resolved:** Your screens show four different bottom-navigation configurations. Architecture doc 01 defines one canonical 5-tab structure (Explore, Search, Trips, Concierge, Profile) that every other prompt builds against.
- **Two missing screens:** `luxetravel_saved_tours.png` and `luxetravel_profile_history.png` were corrupted/empty in your export (0 usable bytes). These are not separate screens in the final IA — they're folded in as segments of the **Trips** tab (Upcoming / History / Saved), matching the pattern already visible in `luxetravel_profile_dashboard.png`. No missing-asset request needed.
- **One screen was inferred:** A **Tour Details** screen sits between "Search Results → View Details" and "Booking Configuration" but wasn't in your export. It's fully specified in Prompt 6 using the same design tokens as the rest of the system.

## What you need to do yourself before/alongside running these prompts (Gemini cannot do these)

These are console/account actions outside of code, listed in the order you'll hit them:

1. **Windows dev environment** (Prompt 1 covers verification): Flutter SDK, Android Studio + Android SDK/emulator, VS Code (or Android Studio) with Flutter/Dart plugins, Git, Node.js LTS (required for Firebase CLI and Cloud Functions).
2. **Firebase project**: create it at console.firebase.google.com, enable Firestore (production mode), Authentication (Email/Password, Google, Apple providers), Storage, Cloud Messaging, Crashlytics, App Check. Install Firebase CLI (`npm install -g firebase-tools`) and run `flutterfire configure` from the project root once Prompt 1/2 scaffolding exists.
3. **Stripe account**: create it at dashboard.stripe.com, grab the **publishable key** (goes in the Flutter app) and **secret key** (goes only in Cloud Functions config via `firebase functions:secrets:set`). Enable Apple Pay and Google Pay in the Stripe dashboard's Payment Methods settings.
4. **Google Cloud / Google Pay**: register for a Google Pay merchant ID (or use Stripe's test merchant ID during development).
5. **Apple Developer account** (needed only once you have the iOS/Mac machine): you'll need this for the Apple Merchant ID (Apple Pay), Sign in with Apple capability, and eventually App Store Connect. Nothing in this kit blocks on it — see the iOS-readiness notes in Prompt 14.

## How to run this with Gemini, given your Windows + Android-only setup today

- You can build **100% of the Dart/Flutter code for both platforms** on Windows. The `ios/` folder, entitlements, and Info.plist are just text/XML — Gemini can generate and edit them on Windows with no Mac required.
- You **cannot compile, sign, or run the iOS app** until you have a Mac. Every iOS-specific step in these prompts is written so Gemini produces the code and config now, and flags clearly which manual Xcode action you'll perform later on the Mac (signing, capability toggles, TestFlight).
- Build and test against **Android** after every prompt (`flutter run -d <android-device-id>`), since that's your deliverable first.
- Keep the prompts in order. Each one assumes the prior modules exist. If you skip ahead, tell Gemini explicitly which prior prompts were already completed so it doesn't re-scaffold things and create duplicates.

## A note on "modular architecture, KISS, SRP"

The architecture doc enforces this concretely, not just as a slogan:
- Every feature is a self-contained folder (`lib/features/<feature>/{data,domain,presentation}`) that only talks to other features through `core` contracts — never directly importing another feature's internals.
- No layer is added unless it earns its place. We deliberately **skip** a heavy use-case/interactor layer for simple CRUD-style features (KISS) but **do** add it for the Booking + Checkout flow, where multi-step business logic (price calculation, payment intent creation, Firestore transaction) genuinely needs it.
- Each class has one reason to change — repositories only fetch/persist data, controllers only hold UI state and call repositories, widgets only render. Gemini is instructed to flag and refuse "god classes" during the build.
