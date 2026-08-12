# Payments API

A payment gateway API built with Ruby on Rails.

> **Status:** work in progress. Authentication, merchants, wallets, and charges (mock pix/card) are implemented; refunds and webhooks come next.

---

## About

A payment gateway focused on real-world flows, security, and an API design that is easy to evolve.

The current milestone covers **identity, merchant onboarding, and charges**: users register with validated CPF/email, authenticate with JWT + refresh tokens, manage their profile, register merchants with BRL wallets, and create pix/card charges via a mock payment provider.

## What's implemented

| Area | Details |
|------|---------|
| Registration | Sign-up with email and CPF validation; returns `access_token`, `refresh_token`, and serialized user |
| Authentication | Login with short-lived JWT access tokens (`access_token` in JSON) |
| Session | Refresh tokens with rotation, SHA-256 digest storage, and revocation on logout |
| Profile | Read, update, and delete your own account (`/me`) |
| Merchants | CRUD for the authenticated user's merchants; CNPJ validation; `legal_name` and `document` on create; `legal_name` on update |
| Wallets | Each merchant gets an `Account` on create (`money-rails`): `available_balance_cents` and `pending_balance_cents` in BRL, starting at zero |
| Charges | Create/list per merchant; show/cancel/confirm by `public_id`; mock provider for pix (manual confirm) and card (auto-succeed) |
| Ledger | Append-only `ledger_entries`; successful charges credit `available_balance_cents` |
| API layer | `Api::V1::BaseController` with shared auth; concerns for authentication, errors, and serialization; Alba serializers for JSON |
| Documentation | OpenAPI via [rswag](https://github.com/rswag/rswag) at `/api-docs` (request schemas with email, password, CPF, and CNPJ hints) |
| Quality | RSpec, SimpleCov, RuboCop, Brakeman, Bundler Audit, and GitHub Actions CI |

### Current endpoints

Protected routes expect `Authorization: Bearer <access_token>`.

```
POST   /api/v1/register          # create account
POST   /api/v1/login             # authenticate
POST   /api/v1/refresh           # renew tokens (body: refresh_token)
DELETE /api/v1/logout            # revoke refresh token (auth + refresh_token in body)
GET    /api/v1/me                # profile
PATCH  /api/v1/me                # update profile
DELETE /api/v1/me                # delete account
GET    /api/v1/merchants         # list my merchants
POST   /api/v1/merchants         # register merchant + wallet
GET    /api/v1/merchants/:id     # merchant + nested account
PATCH  /api/v1/merchants/:id     # update merchant (legal_name)
GET    /api/v1/merchants/:merchant_id/charges
POST   /api/v1/merchants/:merchant_id/charges
GET    /api/v1/charges/:public_id
POST   /api/v1/charges/:public_id/confirm   # mock pix confirmation
POST   /api/v1/charges/:public_id/cancel
```

Interactive docs: `http://localhost:3000/api-docs` (with the API running).

## Stack

- **Ruby** 4.0.4 · **Rails** 8.1 (API-only)
- **PostgreSQL** 16
- **JWT** (HS256) + **bcrypt**
- **Alba** (JSON serializers)
- **money-rails** (BRL balances in cents)
- **cpf_cnpj** · **validators** (CPF, CNPJ, email)
- **RSpec** · SimpleCov · FactoryBot · Faker
- **rswag** (OpenAPI 3)
- **Docker** / Docker Compose
- **GitHub Actions** (lint, security scan, tests)

## Technical decisions

- **Short-lived access token (15 min)** + **long-lived refresh token (30 days)** — reduces the risk window if a JWT leaks.
- **Refresh token stored as a digest** — the plain value is returned once; only the hash is persisted.
- **Rotation on refresh** — the previous token is revoked when a new pair is issued.
- **Explicit logout** — revokes the refresh token tied to the authenticated user.
- **Brazilian domain validations** — CPF and email on users; CNPJ on merchants (`cpf_cnpj`, `validators`).
- **`AuthToken` services** — `issue_for`, `rotate`, and `revoke` keep token logic out of controllers and easy to unit-test.
- **Merchant + account** — user may own many merchants; each create provisions a BRL wallet with zero balance and non-negative balance constraints at the DB level.
- **Alba serializers** — consistent JSON shape; no `password_digest` or timestamps on public user payloads.
- **Controller concerns** — `Authenticatable`, `ErrorRenderable` (including `RecordNotFound` → 404), and `Serializable` for DRY API responses.

## Getting started

### Prerequisites

- Docker and Docker Compose **or**
- Ruby 4.0.4, Bundler, and PostgreSQL 16

### With Docker (recommended)

```bash
docker compose up --build
```

The API will be available at `http://localhost:3000`. Compose installs gems, prepares the database, and starts the server.

### Locally

```bash
bundle install

cp .env .env.development.local
# fill in the variables in .env.development.local

bin/rails db:prepare
bin/rails server
```

For the test suite, also create a test env file:

```bash
cp .env .env.test.local
# fill in the same variables for the test database
```

### Environment variables

Copy `.env` and fill in the values. Required keys:

| Variable | Description |
|----------|-------------|
| `JWT_SECRET` | Secret used to sign and verify JWTs |
| `DATABASE_HOST` | Postgres host |
| `DATABASE_USERNAME` | Database user |
| `DATABASE_PASSWORD` | Database password |
| `DATABASE_PORT` | Port (default `5432`) |

## API documentation

Interactive Swagger UI is available at `http://localhost:3000/api-docs` when the server is running.

To regenerate the OpenAPI spec **with real response examples**, run:

```bash
bin/rails doc:generate
```

This wraps `rswag:specs:swaggerize` with `RSWAG_DRY_RUN=0`, so the request specs actually hit the app. Response bodies are captured into `swagger/v1/swagger.yaml` as examples (see the hook in `spec/swagger_helper.rb`).

## Tests and quality

```bash
bundle exec rspec          # test suite (+ SimpleCov coverage report)
bin/rubocop                # style
bin/brakeman --no-pager    # static security analysis
bin/bundler-audit          # known gem vulnerabilities
```

After the suite finishes, open `coverage/index.html` for the HTML coverage report. The terminal also prints a line coverage summary.

CI runs these checks on pull requests and pushes to the default branch.

## Relevant structure

```
app/
  controllers/api/v1/
    base_controller.rb          # authenticate_user! for protected routes
    merchants_controller.rb
    users/                      # registrations, sessions, me
  controllers/concerns/         # Authenticatable, ErrorRenderable, Serializable
  models/                       # User, RefreshToken, Merchant, Account, Charge, LedgerEntry
  serializers/                  # Alba (User, Merchant, Account, Charge)
  services/
    auth_token/                 # Token encode/decode, Refresh issue/rotate/revoke
    charges/                    # Create, Confirm
    ledger/                     # RecordChargeCredit
    payments/                   # MockProvider
spec/
  models/ requests/ services/
swagger/v1/                     # OpenAPI generated by rswag
db/
  diagram/gateway.dbml          # ER diagram (paste into dbdiagram.io); migrations are source of truth
```

## Roadmap

Planned next steps for the gateway:

1. Refunds and partial refunds
2. Webhooks and idempotency
3. External payment provider integration (beyond mock)
4. Auditing and rate limiting

## License

Free to use for study and demonstration.
