# MVP Travel & Tourism

MVP Travel & Tourism is a cross-platform travel booking app with a customer Flutter app, a Flutter Web admin dashboard, and a custom Node/Express backend API.

## Architecture

### Customer App (`/lib`)
- Tour discovery, booking, checkout, trips, reviews, notifications, profile, and concierge.
- Firebase is kept to free client services such as Auth/Core/Messaging/App Check/Analytics/Crashlytics.
- App data is read and written through `backend_api`.
- Media uploads use Cloudinary through backend-signed upload tokens.

### Admin App (`/admin_app`)
- Staff dashboard for bookings, users, tours, services, audit logs, notifications, staff, and concierge.
- Uses Firebase Auth for sign-in, then calls `backend_api` for authorization and all business data.
- Media uploads use Cloudinary through `backend_api`.

### Backend API (`/backend_api`)
- Node/Express/Prisma API for business logic, catalog, bookings, users, reviews, notifications, payments, audit logging, and media signing.
- Uses Postgres for persistent app data.

## Setup

```bash
flutter pub get
cd admin_app && flutter pub get
cd ../backend_api && npm install
```

## Checks

```bash
dart analyze
flutter test

cd admin_app
dart analyze

cd ../backend_api
npm run build
```

Backend integration tests require a reachable local Postgres instance matching `backend_api/.env`.
