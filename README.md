# CRM App — Flutter + Supabase + n8n

[![CI](https://github.com/nk691929/crm_app_n8n_flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/nk691929/crm_app_n8n_flutter/actions/workflows/ci.yml)

A lightweight lead management CRM built to work alongside n8n-powered form automation for small businesses. Leads are captured through a form, automatically followed up on via n8n, and managed live through a Flutter admin dashboard with enforced business rules, real error handling, and test coverage.

## Overview

This project connects three pieces into one working pipeline:

**Tally Form → n8n (capture workflow) → Supabase (database) → n8n (follow-up automation) → Flutter CRM (admin dashboard)**

- A public lead-capture form (Tally) feeds a webhook into n8n
- n8n parses the submission and writes a new lead into Supabase
- A separate scheduled n8n workflow automatically follows up with quiet leads via email, based on configurable rules
- A Flutter app gives the admin a live, realtime dashboard to view, triage, and manage leads — built with clean architecture, Riverpod, and go_router

## Architecture

```
┌─────────────┐      ┌──────────────┐      ┌──────────────┐
│  Tally Form │ ───▶ │  n8n Webhook │ ───▶ │   Supabase   │
└─────────────┘      │   Workflow   │      │  (Postgres)  │
                      └──────────────┘      └──────┬───────┘
                                                    │
                      ┌──────────────┐              │ realtime
                      │  n8n Follow- │ ◀────────────┤ subscription
                      │  Up Workflow │              │
                      │  (scheduled) │              ▼
                      └──────────────┘      ┌──────────────┐
                                             │  Flutter App │
                                             │  (Admin CRM) │
                                             └──────────────┘
```

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (clean architecture, Riverpod, go_router) |
| Backend / Database | Supabase (Postgres, Auth, Realtime, Row Level Security) |
| Automation | n8n (self-hosted) |
| Form intake | Tally |
| Notifications | Email (Gmail node via n8n) |
| Testing | flutter_test — unit tests on use cases, widget tests on screen states |
| CI | GitHub Actions — format, analyze, and test on every PR |

## Features

- **Live lead pipeline** — leads grouped by status (New, Contacted, Qualified, Won, Lost), updating in real time via Supabase's realtime subscriptions
- **Enforced status transitions** — a use-case layer (`UpdateLeadStatus`) blocks invalid moves (e.g. reopening a Won lead straight back to New), and automatically resets or clears the n8n follow-up schedule (`next_follow_up_at`, `follow_up_count`) when a lead closes or reopens
- **Automated follow-ups** — a scheduled n8n workflow nudges leads who've gone quiet, capped at a configurable number of attempts
- **Activity log per lead** — automatic system entries (status/priority changes) alongside n8n's outbound follow-up emails, in one combined timeline
- **Notes log** — freeform admin notes per lead
- **Search and priority filter** — client-side filtering over the already-loaded realtime list, no extra network round trip
- **Admin authentication** — Supabase Auth gates access; Row Level Security restricts every table to authenticated users only
- **Light and dark mode** — theme-aware across every screen, following the system setting
- **Sealed error handling** — a `Result<T>`/`Failure` pattern maps every Supabase exception to a typed, user-safe failure; no raw exceptions reach the UI
- **Clean architecture** — domain layer has zero Supabase dependency; data layer implements domain contracts; presentation layer is Riverpod-driven and testable via provider overrides

## Testing

```bash
flutter test
```

- **Unit tests** (`test/features/leads/domain/usecases/`) cover `UpdateLeadStatus`'s full transition table against a hand-written fake repository — no Supabase, no widgets, fully isolated business logic.
- **Widget tests** (`test/features/leads/presentation/`) cover the dashboard's loading, data, and error states using Riverpod's `overrideWith` to inject fake streams.

## Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── supabase_config.dart        # Supabase client setup, .env loading
│   ├── error/
│   │   ├── failures.dart               # Sealed Failure types
│   │   ├── result.dart                 # Sealed Result<T> (Success/Err)
│   │   ├── failure_mapper.dart         # Maps raw exceptions -> Failure
│   │   ├── guard.dart                  # try/catch wrapper for Future/Stream
│   │   └── exceptions.dart             # NoRowsAffectedException, etc.
│   ├── providers/
│   │   └── supabase_provider.dart      # Injectable SupabaseClient
│   ├── router/
│   │   ├── app_router.dart             # go_router config, auth redirects
│   │   └── app_routes.dart             # Route path constants
│   └── theme/
│       └── app_theme.dart              # Light/dark ColorScheme, status/priority accents
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── app_user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_providers.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── splash_screen.dart
│   │       └── widgets/
│   └── leads/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── leads_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── lead_model.dart
│       │   │   ├── lead_note_model.dart
│       │   │   └── interaction_model.dart
│       │   └── repositories/
│       │       └── leads_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── lead.dart
│       │   │   ├── lead_note.dart
│       │   │   └── interaction.dart
│       │   ├── repositories/
│       │   │   └── leads_repository.dart
│       │   └── usecases/
│       │       ├── update_lead_status.dart   # Transition rules + schedule reset
│       │       └── add_lead_note.dart        # Note validation
│       └── presentation/
│           ├── providers/
│           │   ├── leads_providers.dart
│           │   └── leads_filter_provider.dart
│           ├── screens/
│           │   ├── dashboard_screen.dart
│           │   └── lead_detail_screen.dart
│           └── widgets/
│               └── lead_card.dart
└── main.dart

test/
└── features/leads/
    ├── domain/usecases/
    │   └── update_lead_status_test.dart   # 11 tests: transitions, no-op, failure propagation
    ├── presentation/
    │   └── dashboard_screen_test.dart     # loading / data / error states
    └── fakes/
        ├── fake_leads_repository.dart
        └── test_lead.dart
```

## Database Schema (Supabase)

-- CRM App — Supabase schema
-- Reconstructed from the live database via information_schema and pg_policies.
-- Run this against a fresh Supabase project to recreate the schema used by
-- this app and its n8n workflows.

-- ============================================================
-- Tables
-- ============================================================

create table leads (
  id                  uuid primary key default gen_random_uuid(),
  name                text not null,
  phone               text not null,
  source              text default 'whatsapp',
  status              text not null default 'New',
  priority            text default 'Medium',
  email               text,
  service_interested  text,
  budget              text,
  message             text,
  assigned_to         text,
  last_contacted_at   timestamptz,
  next_follow_up_at   timestamptz,
  follow_up_count     integer default 0,
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

create table notes (
  id          uuid primary key default gen_random_uuid(),
  lead_id     uuid references leads(id) on delete cascade,
  note        text not null,
  created_at  timestamptz default now()
);

create table interactions (
  id          uuid primary key default gen_random_uuid(),
  lead_id     uuid references leads(id) on delete cascade,
  message     text not null,
  direction   text not null,
  created_at  timestamptz default now(),

  constraint interactions_direction_check
    check (direction = any (array['outbound', 'inbound', 'system']))
);
-- direction values:
--   'outbound' — n8n's automated follow-up emails
--   'inbound'  — reserved for future incoming-message logging
--   'system'   — app-originated entries (status/priority changes)

create index interactions_lead_id_idx on interactions(lead_id);
create index notes_lead_id_idx on notes(lead_id);

-- ============================================================
-- Row Level Security
-- ============================================================
-- All three tables are restricted to the `authenticated` role only,
-- scoped per operation. The Flutter app signs in via Supabase Auth and
-- is bound by these policies. n8n authenticates with the `service_role`
-- key, which bypasses RLS entirely by design — it never uses the
-- `authenticated` role, so these policies never apply to it.
--
-- NOTE: this project initially shipped with a single
-- "Allow all for anon" (role: public) policy on all three tables —
-- readable and writable by anyone with the public API key, no login
-- required. The statements below are the audited, corrected version.

alter table leads enable row level security;
alter table notes enable row level security;
alter table interactions enable row level security;

create policy "Authenticated can read leads"
  on leads for select to authenticated using (true);
create policy "Authenticated can insert leads"
  on leads for insert to authenticated with check (true);
create policy "Authenticated can update leads"
  on leads for update to authenticated using (true) with check (true);
create policy "Authenticated can delete leads"
  on leads for delete to authenticated using (true);

create policy "Authenticated can read notes"
  on notes for select to authenticated using (true);
create policy "Authenticated can insert notes"
  on notes for insert to authenticated with check (true);

create policy "Authenticated can read interactions"
  on interactions for select to authenticated using (true);
create policy "Authenticated can insert interactions"
  on interactions for insert to authenticated with check (true);

## Notable bugs found and fixed during development

Kept here deliberately — these were real issues in a working system, not staged for a portfolio:

- **RLS gap:** all three tables initially shipped with a public `"Allow all for anon"` policy — readable and writable by anyone with the public API key, no login required. Audited and restricted to `authenticated`-only.
- **n8n field mapping:** the follow-up workflow's `Create a row` node wrote `id` instead of `lead_id` on `interactions`, silently orphaning every automated follow-up log (never displayed, since nothing matched a real lead).
- **Check constraint mismatch:** `interactions_direction_check` only allowed n8n's original two values (`inbound`/`outbound`); app-originated log entries needed a third (`system`), added after the constraint rejected the first write.

## Setup

### 1. Supabase

1. Create a new Supabase project
2. Run `sql/schema.sql` to create tables, policies, and constraints
3. Enable Realtime on the `leads` table
4. Create an admin user under **Authentication > Users**
5. Note your Project URL and `anon`/`publishable` key (for the app) and `service_role` key (for n8n only — never expose client-side)

### 2. n8n

1. Set up a Webhook trigger to receive Tally form submissions
2. Add a Code node to normalize Tally's dropdown field format into flat values
3. Add a Supabase node (Insert) to write new leads — see `n8n/intake-workflow.json`
4. Import the scheduled follow-up workflow — see `n8n/follow-up-workflow.json`

### 3. Flutter app

1. Clone this repo
2. Copy `.env.example` to `.env` and fill in your Supabase values:
   ```
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```
3. Install dependencies and run:
   ```bash
   flutter pub get
   flutter run
   ```

### Building a release APK

```bash
flutter build apk --release
```

Requires `<uses-permission android:name="android.permission.INTERNET" />` in `android/app/src/main/AndroidManifest.xml` (release builds don't get this implicitly, unlike debug builds).

## Roadmap

- [ ] Reconnect WhatsApp as a follow-up channel once WhatsApp Business API access is restored
- [ ] Multi-user support (team assignment via `assigned_to`)
- [ ] Per-client data isolation for multi-tenant use

## License

Private project — not currently licensed for reuse.