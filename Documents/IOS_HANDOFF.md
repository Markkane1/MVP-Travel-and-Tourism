# iOS Handoff Checklist

Everything you need to do the first day you have a Mac with Xcode.
**No further code changes required** — this is pure Xcode configuration and store submission.

---

## Prerequisites Before Opening Xcode

- [ ] Enroll in the **Apple Developer Program** at https://developer.apple.com/enroll ($99/year, requires Apple ID + payment).
- [ ] Register a real **Apple Pay Merchant ID** at https://developer.apple.com/account/resources/identifiers/merchant/add.
  - Replace `merchant.TODO_REPLACE_WITH_REAL_MERCHANT_ID` in `ios/Runner/Runner.entitlements` with the actual ID (e.g. `merchant.com.mvptravelandtourism.app`).
- [ ] Add your Mac to your Apple Developer account (Certificates, Identifiers & Profiles > Devices).

---

## Step 1: Open the Project in Xcode

```bash
open ios/Runner.xcworkspace
```

> **Important**: Always open `.xcworkspace`, NOT `.xcodeproj` — the workspace includes CocoaPods dependencies.

---

## Step 2: Set the Development Team & Bundle ID

1. Select the **Runner** target in the left panel.
2. Go to **Signing & Capabilities** tab.
3. Under **Team**, select your Apple Developer account.
4. Confirm **Bundle Identifier** is `com.mvptravelandtourism.app` (production) or `com.mvptravelandtourism.app.dev` (dev flavor).
5. Let Xcode auto-manage provisioning profiles (tick **Automatically manage signing**).

---

## Step 3: Register Capabilities (entitlements file alone is NOT sufficient)

The `ios/Runner/Runner.entitlements` file declares the capabilities, but Xcode must also register them against your Apple Developer account:

### Sign in with Apple
1. In **Signing & Capabilities**, click **+ Capability**.
2. Add **Sign in with Apple**.
3. Xcode will update your App ID on the Apple Developer portal automatically.

### Apple Pay
1. Click **+ Capability** → **Apple Pay**.
2. Add your registered merchant ID (the one you created in prerequisites).
3. Xcode registers the merchant ID against your App ID.

### Push Notifications
1. Click **+ Capability** → **Push Notifications**.
2. Go to https://console.firebase.google.com → Project Settings → Cloud Messaging → Upload APNs certificate or key.
   - Recommended: use APNs Auth Key (`.p8` file) — valid for all apps in your account, doesn't expire annually.
   - Alternative: APNs certificate (`.p12`) — expires yearly.

---

## Step 4: Run on a Real iOS Device or Simulator

```bash
# List available simulators
xcrun simctl list devices

# Run on simulator from command line
flutter run --flavor prod --dart-define=FLAVOR=prod

# Or run directly from Xcode: Product → Run (⌘R)
```

For a physical device:
1. Connect device via USB.
2. Trust the Mac on the device.
3. Select device in Xcode's scheme selector.
4. Build & Run.

---

## Step 5: Archive and Upload to TestFlight / App Store Connect

### Archive
1. In Xcode, set the scheme to **Runner (prod)** and destination to **Any iOS Device (arm64)**.
2. **Product → Archive** (⌘⇧B won't work — must use Archive).
3. The Organizer window opens automatically when archiving completes.

### Upload to App Store Connect
1. In Organizer, select the archive → **Distribute App**.
2. Choose **App Store Connect** → **Upload**.
3. Follow the wizard; let Xcode manage signing.
4. The build appears in App Store Connect → TestFlight within ~10 minutes.

### Alternatively (from command line):
```bash
flutter build ipa --flavor prod --dart-define=FLAVOR=prod
# Then upload the .ipa via Transporter app or xcrun altool
```

---

## Step 6: App Store Submission Checklist (in App Store Connect)

- [ ] Set **Privacy Policy URL** (must be a real public URL, not just the in-app screen) — host the `/legal/privacy` content at your domain.
- [ ] Complete **App Privacy** data collection questionnaire (auth email, payment info, location, device ID).
- [ ] Upload **screenshots** for iPhone 6.7", iPhone 6.5", iPad Pro 12.9" (minimum required sizes).
- [ ] Fill in **App Description**, **Keywords**, **Support URL**.
- [ ] Complete **Content Rating** questionnaire.
- [ ] Submit for App Review.

---

## Known "Gotcha" Notes

| Issue | Solution |
|-------|---------|
| `pod install` fails | Run `cd ios && pod install --repo-update` |
| Google Maps blank on device | Add `GMSServices.provideAPIKey("YOUR_KEY")` in `AppDelegate.swift` (already stubbed) |
| APNs push not arriving on iOS simulator | Simulators don't support real APNs — test on a physical device |
| "No provisioning profile" error | Check that the Bundle ID in Xcode matches the App ID registered in your Developer account |
| Flutter build fails after Xcode update | Run `flutter clean && flutter pub get` then rebuild |
