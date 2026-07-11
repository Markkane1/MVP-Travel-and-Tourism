# MVP Travel & Tourism

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

MVP Travel & Tourism is a cross-platform, premium travel and tourism booking ecosystem. It provides users with a seamless end-to-end booking experience, comprehensive itinerary management, and an integrated digital concierge.

The repository consists of a primary customer-facing Flutter application, an isolated administrative dashboard, and a secure serverless backend powered by Firebase Cloud Functions.

---

## 🏛 Project Architecture

The repository is structured into three primary domains to ensure security, maintainability, and clear separation of concerns.

### 1. Customer Application (`/lib`)
The main cross-platform Flutter application tailored for travelers. 
- **Features:** Tour discovery, interactive maps, secure checkout (via Stripe), itinerary viewing, profile management, and a real-time digital concierge.
- **State Management:** Riverpod (using clean architecture with `Repository` -> `UseCase` -> `Controller` patterns).
- **Routing:** GoRouter for robust declarative routing and deep linking.

### 2. Administrative Dashboard (`/admin_app`)
A dedicated Flutter Web application for MVP Travel staff.
- **Features:** Centralized dashboard for managing tours, staff accounts, customer bookings, audit logs, and responding to concierge threads.
- **Security:** Requires strict `admin` or `staff` custom claims. Direct database writes are heavily restricted; actions are routed through secure Cloud Functions to enforce audit logging.

### 3. Serverless Backend (`/functions`)
The authoritative source of truth for all business logic, built on Firebase Cloud Functions (TypeScript).
- **Features:** Server-side price calculation, booking confirmation, GDPR-compliant data deletion, payment webhooks, and secure audit logging.
- **Security:** Strict Firestore Security Rules ensure clients can only read/write data they explicitly own.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- Node.js & npm (for Firebase Functions)
- Firebase CLI (`npm install -g firebase-tools`)

### Initial Setup

1. **Install Dependencies**
   ```bash
   flutter pub get
   cd admin_app && flutter pub get
   cd ../functions && npm install
   ```

2. **Database Seeding**
   To populate your local or development Firestore instance with initial tours and state, run the provided tooling scripts:
   ```bash
   dart run tool/seed_tours.dart
   dart run tool/seed_demo_state.dart
   ```

3. **Running the Apps**
   - **Customer App:** `flutter run`
   - **Admin App:** `cd admin_app && flutter run -d chrome`

---

## 🧪 Testing

The repository maintains a rigorous standard of testing, all consolidated under the unified `/test` directory.

- **Unit & Widget Tests:** Run `flutter test` from the root directory to execute all business logic and UI component tests.
- **Integration Tests:** End-to-end traveler journeys and screen coverage tests are located in `/test/integration/`. 
  Run them via: `flutter test test/integration/critical_path_test.dart`

---

## 🔒 Security & Privacy

This application enforces strict security and GDPR-compliant privacy standards:
- **Zero Client-Side Trust:** All sensitive operations (pricing, refunds, staff interactions) are strictly mediated by Cloud Functions.
- **Audit Logging:** Every administrative action is permanently recorded in the `admin_audit_logs` collection.
- **GDPR Compliance:** Users can permanently delete their accounts and all associated personally identifiable data with a single tap, safely executed via the `cleanupUserData` Cloud Function.

---

*Built for MVP Travel and Tourism LLC.*
