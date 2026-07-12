# Complete API Design - MVP Travel and Tourism

Date: 2026-07-12
Status: Approved design draft
Scope: Define the complete custom backend API as a standalone replacement backend. This document is only about building the API itself, not the migration from Firebase.

## 1. Goal

Build a full-fledged backend API in a new workspace folder, `backend_api/`, that becomes the long-term system of record for:

- authentication
- authorization
- bookings
- payments
- refunds
- tours and services management
- reviews
- concierge/support messaging
- notifications
- media handling
- audit logging
- account lifecycle operations

This API is designed as the permanent backend for the product.

## 2. Non-Goals

This document does not define:

- phased migration from Firebase
- Flutter app rewiring steps
- temporary compatibility bridges
- Firestore coexistence strategy

Those belong in a separate migration spec.

## 3. Target Stack

Recommended stack:

- Node.js
- Express
- TypeScript
- PostgreSQL
- JWT auth owned by us
- Cloudinary for media
- Stripe for payments/refunds
- VPS deployment with Nginx

Why this stack:

- shortest path to a serious custom backend
- strong fit for relational business data
- full control of auth and authorization
- clean fit for future scaling

## 4. System Responsibilities

The API is responsible for all trusted operations:

- identity issuance and session control
- password-based auth and refresh handling
- role and permission enforcement
- customer and staff account management
- bookings and booking transitions
- payment intent creation
- webhook handling
- refund execution
- loyalty/reward logic
- review validation
- concierge message handling
- notifications
- signed or controlled media flows
- audit logging
- deletion/anonymization workflows

## 5. Core Architecture

### 5.1 Backend shape

Single deployable API service.

Use a modular monolith:

- one codebase
- one API
- one database
- clear internal modules

This avoids fake microservice complexity.

### 5.2 Internal modules

Recommended modules:

- `auth`
- `users`
- `staff`
- `bookings`
- `payments`
- `refunds`
- `tours`
- `services`
- `reviews`
- `concierge`
- `notifications`
- `media`
- `audit`
- `account_lifecycle`

## 6. Auth Design

### 6.1 Auth model

Auth is owned by the API.

Recommended model:

- email/password login
- JWT access token
- refresh token rotation
- hashed passwords
- server-side session tracking

### 6.2 Required auth endpoints

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `POST /auth/logout-all`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `GET /auth/me`

### 6.3 Auth rules

- access tokens are short-lived
- refresh tokens are revocable
- passwords stored hashed only
- session revocation supported
- admin role is never client-declared

## 7. Authorization Design

### 7.1 Roles

Recommended minimum roles:

- `customer`
- `admin`
- `super_admin`
- `concierge`

### 7.2 Authorization source

Authorization is database-backed.

Use:

- user record
- staff profile / role assignment
- active/inactive status
- route-level permission guards

### 7.3 Required guards

- authenticated user
- active staff
- admin-only
- super-admin-only
- self-only access
- resource ownership guard

## 8. Database Design

### 8.1 Database choice

Use PostgreSQL.

Why:

- bookings, refunds, reviews, roles, notifications, concierge, and reporting are relational
- better fit than document-first storage for long-term operations

### 8.2 Core tables

Recommended tables:

- `users`
- `staff_profiles`
- `sessions`
- `bookings`
- `booking_status_history`
- `payments`
- `refunds`
- `tours`
- `tour_media`
- `tour_reviews`
- `services`
- `service_media`
- `concierge_threads`
- `concierge_messages`
- `notifications`
- `audit_logs`
- `media_assets`

### 8.3 Important table intent

#### users

- identity
- profile
- loyalty
- tier
- status

#### staff_profiles

- role
- active flag
- admin metadata

#### bookings

- booking state
- pricing snapshot
- customer linkage
- payment linkage

#### payments

- payment provider state
- amount/currency
- payment intent references

#### refunds

- refund lifecycle
- refund state
- operator and reason

#### audit_logs

- append-only privileged action trail

## 9. API Surface

## 9.1 Route groups

- `/health`
- `/auth`
- `/users`
- `/admin/users`
- `/admin/staff`
- `/admin/bookings`
- `/admin/tours`
- `/admin/services`
- `/admin/reviews`
- `/admin/concierge`
- `/admin/notifications`
- `/bookings`
- `/payments`
- `/reviews`
- `/concierge`
- `/media`
- `/webhooks`

### 9.2 Core routes

#### Health

- `GET /health`

#### Auth

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me`

#### User self-service

- `GET /users/me`
- `PATCH /users/me`
- `DELETE /users/me`

#### Bookings

- `POST /bookings`
- `GET /bookings/:id`
- `GET /users/me/bookings`
- `POST /bookings/:id/cancel`

#### Payments

- `POST /payments/create-intent`
- `GET /payments/:id`

#### Reviews

- `POST /reviews`
- `PATCH /reviews/:id`
- `DELETE /reviews/:id`

#### Concierge

- `GET /concierge/threads/me`
- `GET /concierge/threads/me/messages`
- `POST /concierge/threads/me/messages`

#### Admin users

- `POST /admin/users`
- `PATCH /admin/users/:id`
- `DELETE /admin/users/:id`

#### Admin staff

- `POST /admin/staff`
- `PATCH /admin/staff/:id`
- `POST /admin/staff/:id/deactivate`

#### Admin bookings

- `POST /admin/bookings/:id/status`
- `POST /admin/bookings/:id/refund`

#### Admin tours

- `POST /admin/tours`
- `PATCH /admin/tours/:id`
- `DELETE /admin/tours/:id`

#### Admin services

- `POST /admin/services`
- `PATCH /admin/services/:id`
- `DELETE /admin/services/:id`

#### Admin reviews

- `POST /admin/reviews/:id/reward`

#### Admin concierge

- `POST /admin/concierge/:userId/reply`

#### Admin notifications

- `POST /admin/notifications/send`

#### Media

- `POST /media/upload-token`
- `POST /media/complete`
- `DELETE /media/:id`

#### Webhooks

- `POST /webhooks/stripe`

## 10. Service Layer

Recommended services:

- `AuthService`
- `SessionService`
- `UserService`
- `StaffService`
- `BookingService`
- `PaymentService`
- `RefundService`
- `ReviewService`
- `ConciergeService`
- `NotificationService`
- `MediaService`
- `AuditLogService`
- `AccountLifecycleService`

### 10.1 Service rules

- business rules live in services
- controllers stay thin
- repositories stay persistence-only

## 11. Repository Layer

Recommended repositories:

- `UserRepository`
- `StaffRepository`
- `SessionRepository`
- `BookingRepository`
- `PaymentRepository`
- `RefundRepository`
- `TourRepository`
- `ServiceRepository`
- `ReviewRepository`
- `ConciergeRepository`
- `NotificationRepository`
- `MediaRepository`
- `AuditLogRepository`

## 12. Media Design

### 12.1 Provider

Use Cloudinary for image/media hosting.

### 12.2 Media rules

- do not allow privileged unsigned uploads
- uploads must be controlled by API-issued signed or constrained flows
- media records are persisted in database
- app never invents trusted media paths on its own

### 12.3 Media classes

- public tour media
- public service media
- user profile media
- review media
- concierge attachment media

Each class should have its own storage/path policy.

## 13. Payment Design

### 13.1 Provider

Use Stripe through the custom API.

### 13.2 Payment responsibilities

- create payment intents
- persist provider references
- verify webhooks
- confirm booking after verified payment
- process refunds
- keep idempotent records

### 13.3 Required controls

- idempotency keys
- webhook signature verification
- no client-side booking confirmation
- refund flow not inside retryable DB transaction callback

## 14. Notification Design

Phase 1 API should support:

- in-app notifications
- admin-originated notification writes

Later expansion:

- email
- push delivery workers

## 15. Review and Loyalty Design

API should own:

- review submission validation
- one-review-per-booking enforcement
- completed-booking enforcement
- reward issuance
- reviewed-state updates

No client-trusted reward flow.

## 16. Account Lifecycle Design

### 16.1 User deletion

The API must define one clear deletion policy:

- hard delete where safe
- anonymize where business retention is required

### 16.2 Deletion rules

- cleanup order is server-controlled
- auth/session invalidation is server-controlled
- no deletion success until cleanup policy completes

## 17. Security Controls

Required controls:

- JWT verification
- refresh token rotation
- password hashing
- route validation
- CORS allowlist
- rate limiting
- raw-body Stripe webhook handling
- backend-only audit logs
- admin and super-admin guards
- structured error handling

## 18. Audit Logging

All privileged mutations must write append-only audit events.

Required fields:

- actor ID
- actor email or username
- actor role
- action
- target type
- target ID
- summary
- before/after snapshot where appropriate
- timestamp

## 19. Backend Folder Structure

```text
backend_api/
  package.json
  tsconfig.json
  .env.example
  src/
    app.ts
    server.ts
    config/
    lib/
    middleware/
    routes/
    controllers/
    services/
    repositories/
    validators/
    types/
  tests/
```

## 20. Deployment Design

Recommended:

- VPS
- Nginx
- Node process manager (`pm2` or `systemd`)
- TLS at reverse proxy
- environment-separated secrets
- CI/CD later if desired

## 21. Testing Strategy

Required test layers:

- unit tests for services
- route tests for auth/authorization/validation
- integration tests for DB behavior
- Stripe webhook tests
- refund/payment idempotency tests

## 22. Implementation Phases

1. backend skeleton
2. auth and session module
3. user and staff modules
4. bookings and payments
5. refunds and webhooks
6. tours/services/reviews
7. concierge and notifications
8. media flows
9. deletion/audit hardening

## 23. Final Recommendation

Build `backend_api/` as the permanent backend using:

- Express + TypeScript
- Postgres
- owned JWT auth
- Cloudinary
- Stripe

This gives the product a full backend under our control and cleanly ends dependence on Firebase as a platform architecture.
