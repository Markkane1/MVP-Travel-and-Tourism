# Firebase to API Migration Design - MVP Travel and Tourism

Date: 2026-07-12
Status: Approved design draft
Scope: Define the migration from the current Firebase-based architecture to the complete custom API described in `2026-07-12-complete-api-design.md`.

## 1. Goal

Replace Firebase from the product in controlled stages:

- Firebase Functions
- Firestore
- Firebase Auth
- Firebase Storage

without forcing a single destructive rewrite.

## 2. Current State

Current architecture still depends on:

- Firebase Auth
- Firestore
- Firebase Functions
- Firebase rules
- some Firebase Storage/media assumptions

The current apps are not to be changed immediately.

## 3. Migration Principles

1. one trust boundary at a time
2. one subsystem at a time
3. no big-bang replacement
4. keep app behavior stable while backend ownership moves
5. remove Firebase only after equivalent API behavior exists

## 4. Migration Order

Recommended order:

1. build custom API
2. replace Firebase Functions
3. introduce Postgres as source of truth
4. migrate auth to owned JWT auth
5. migrate media to Cloudinary
6. remove Firestore dependencies from app
7. retire Firebase completely

## 5. Phase 1 - Build API Without App Rewiring

Create `backend_api/` and implement the complete backend skeleton.

Outputs:

- health route
- auth module
- admin guards
- database layer
- core service modules

App impact:

- none yet

## 6. Phase 2 - Replace Firebase Functions First

Move privileged server logic into the API:

- admin user flows
- staff flows
- booking status updates
- refunds
- payment intent creation
- Stripe webhook
- account cleanup
- booking cancellation

During this phase, Firebase Auth and Firestore may still coexist temporarily.

App impact:

- later route rewiring only
- no database migration yet

## 7. Phase 3 - Introduce Postgres as Source of Truth

Create the relational schema and begin moving core business entities to Postgres:

- users
- staff
- bookings
- payments
- refunds
- reviews
- concierge
- notifications
- tours/services
- audit logs

Strategy:

- write canonical data into Postgres
- keep compatibility views or synchronization only where needed

Rule:

- do not keep indefinite dual-source truth

## 8. Phase 4 - Migrate Authentication

Replace Firebase Auth with owned auth.

New auth model:

- API-owned user registration/login
- JWT access token
- refresh token rotation
- server-side session invalidation

Migration tasks:

- add auth endpoints
- create password hashing
- migrate user identities
- update app login/register/session flows later

## 9. Phase 5 - Replace Storage/Media

Replace Firebase Storage with Cloudinary.

Migration tasks:

- define media classes
- define upload policy
- issue signed or controlled upload instructions
- move existing public media references

## 10. Phase 6 - Rewire App Reads/Writes

App code begins switching from Firebase SDK usage to API usage.

Order:

1. privileged writes
2. auth/session flows
3. booking/payment flows
4. admin workflows
5. general reads

Rule:

- migrate high-risk writes before lower-risk reads

## 11. Phase 7 - Retire Firestore

Once all business-critical reads and writes are API-backed:

- remove Firestore usage from app
- remove Firestore rules from operational architecture
- freeze old data path

## 12. Phase 8 - Retire Firebase Fully

After auth, database, server logic, and media are all replaced:

- remove Firebase packages from apps
- remove Firebase project dependency
- remove Firebase deploy workflows

## 13. Exact Firebase Replacement Map

### Replace first

- Firebase Functions -> custom API

### Replace second

- Firestore writes for privileged/business logic -> API + Postgres

### Replace third

- Firebase Auth -> owned JWT auth

### Replace fourth

- Firebase Storage/media -> Cloudinary

## 14. Data Migration Strategy

Recommended:

- export Firebase data
- transform into Postgres import shape
- import into staging first
- validate counts and referential integrity
- cut over by subsystem

Do not do manual row-by-row migration in production.

## 15. Compatibility Period

There will be a temporary mixed period where:

- apps still use Firebase in places
- API exists and owns new backend behavior

That period must be intentionally short.

Goal:

- use it as a bridge, not a permanent architecture

## 16. Risks

Main migration risks:

- duplicate sources of truth
- auth mismatch during cutover
- broken booking/payment flows
- media URL drift
- role/permission inconsistencies

Mitigation:

- migrate one subsystem at a time
- keep exact endpoint contracts documented
- verify parity before disabling Firebase paths

## 17. Testing Requirements

For each migration phase:

- parity test before cutover
- rollback path defined
- staging verification
- production smoke test

## 18. Rollback Rules

Each subsystem migration must have:

- cutover point
- rollback decision
- previous source still recoverable until verification completes

No irreversible removal before parity validation.

## 19. Final Recommendation

Use the complete API spec as the target architecture.

Use this migration spec only as the controlled path from:

- Firebase-dependent product

to:

- fully owned backend architecture

The system should end with no Firebase dependency in runtime-critical paths.
