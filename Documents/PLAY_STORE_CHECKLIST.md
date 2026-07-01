# Google Play Store — Release Readiness Checklist

Status key: ✅ Done in code | 🔴 Requires YOUR direct action | ⚠️ Partially done

---

## Release Build

| Item | Status | Notes |
|------|--------|-------|
| Product flavors (dev / prod) | ✅ | `android/app/build.gradle.kts` configured |
| Release signing keystore | 🔴 | Run `keytool` (see below), fill in `android/key.properties` |
| `flutter build appbundle --flavor prod` succeeds | ✅ | Verified in CI |
| `key.properties` gitignored | ✅ | Already in `.gitignore` |

### Generate the Keystore (one-time — do this now)
```bash
keytool -genkey -v \
  -keystore android/mvp_travel_keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias mvp_travel_key
```
Then fill the passwords into `android/key.properties`.
> ⚠️ **Back up the keystore and passwords securely.** If you lose them you cannot update your app on the Play Store — ever.

---

## Play Console — Requires Your Direct Action 🔴

### 1. Privacy Policy URL (🔴 Must be a real public URL)
- The app has an in-app `/legal/privacy` screen, but **Play Store requires a publicly accessible URL**.
- Action: Host the privacy policy content on your domain (e.g. `https://mvptravel.com/privacy`).
  - Simplest option: copy the text from `lib/features/auth/presentation/screens/legal_placeholder_screen.dart` into a simple HTML page deployed to Firebase Hosting or any static host.
- Enter this URL in Play Console → App content → Privacy policy.

### 2. Data Safety Form (🔴 Must complete in Play Console)
Fill out the **Data safety** section. MVP Travel collects:

| Data type | Collected | Shared | Required disclosure |
|-----------|-----------|--------|---------------------|
| Email address | ✅ | No | Account registration |
| Name | ✅ | No | User profile |
| Photos & videos | ✅ (user-uploaded) | No | Profile photo, review images |
| Location (approximate) | ✅ | No | Travel map |
| Financial info (payment) | ✅ (display only — no raw card data in Firestore) | No | Payment method display |
| Firebase / Crashlytics device IDs | ✅ | Firebase (processor) | Crash reporting, analytics |

Action: In Play Console → App content → Data safety → complete all questions honestly.

### 3. Content Rating Questionnaire (🔴 Complete in Play Console)
- Play Console → App content → App content → Content rating.
- Answer the IARC questionnaire. Expected rating: **Everyone / PEGI 3** (no violence, no mature content).

### 4. App Review Screenshots (🔴 Upload in Play Console)
Minimum required:
- Phone: 2 screenshots minimum (1080×1920 recommended)
- 7" tablet and 10" tablet: optional but recommended for better listing

### 5. App Listing Content (🔴 Fill in Play Console)
- Short description (80 chars max)
- Full description (4000 chars max)
- Feature graphic (1024×500)
- App icon (512×512) — use the same compass icon generated at `assets/icons/app_icon.png`

---

## Suggested Release Process

1. Generate keystore → fill `key.properties`.
2. Run `flutter build appbundle --flavor prod --dart-define=FLAVOR=prod`.
3. Upload `.aab` from `build/app/outputs/bundle/prodRelease/` to Play Console → Internal testing.
4. Test on a real device via the internal track.
5. Complete all 🔴 items above.
6. Graduate to Closed Testing → Open Testing → Production when ready.
