# CRM App — Flutter + Supabase + n8n

A lightweight lead management CRM built to work alongside n8n-powered WhatsApp/form automation for small businesses. Leads are captured through a form, automatically stored and followed up on via n8n, and managed live through a Flutter admin dashboard.

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

## Features

- **Live lead pipeline** — leads grouped by status (New, Contacted, Qualified, Won, Lost), updating in real time via Supabase's realtime subscriptions with no manual refresh
- **Automated follow-ups** — a scheduled n8n workflow nudges leads who've gone quiet, capped at a configurable number of attempts, and logs every touch
- **Admin authentication** — Supabase Auth gates access to the dashboard; RLS policies restrict data access to authenticated users
- **Lead detail view** — inline status/priority editing and a running notes log per lead
- **Clean architecture** — domain layer has zero framework/Supabase dependencies; data layer implements the domain contracts; presentation layer is Riverpod-driven

## Project Structure

```
lib/
├── core/
│   ├── config/          # Supabase client setup, environment config
│   ├── router/           # go_router configuration with auth-based redirects
│   ├── providers/         # Shared Riverpod providers (e.g. SupabaseClient)
│   └── theme/
├── features/
│   ├── auth/
│   │   ├── domain/        # AppUser entity, AuthRepository contract
│   │   ├── data/          # Supabase implementation
│   │   └── presentation/  # Riverpod providers, login screen
│   └── leads/
│       ├── domain/        # Lead entity, LeadsRepository contract
│       ├── data/          # Supabase realtime implementation
│       └── presentation/  # Providers, dashboard, lead detail screen
└── main.dart
```

## Database Schema (Supabase)

**`leads`**

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `name` | text | |
| `phone` | text | Unique, required |
| `email` | text | |
| `service_interested` | text | |
| `budget` | text | |
| `message` | text | |
| `status` | text | `New`, `Contacted`, `Qualified`, `Won`, `Lost` |
| `priority` | text | `High`, `Medium`, `Low` |
| `assigned_to` | text | |
| `created_at` / `updated_at` | timestamptz | Auto-managed |
| `last_contacted_at` | timestamptz | Set by the follow-up workflow |
| `next_follow_up_at` | timestamptz | Set at creation, advanced by the follow-up workflow |
| `follow_up_count` | integer | Caps automated follow-up attempts |

**`interactions`** — logs every outbound touch (message, direction, timestamp), linked to `leads` via `lead_id`.

**`notes`** — freeform admin notes per lead, linked via `lead_id`.

Security: interactions, notes, and leads tables were
initially misconfigured with a public "Allow all for anon" policy,
allowing unauthenticated read/write access. Audited and fixed by
restricting all policies to the authenticated role; verified the
anon key is rejected while the app and the service_role-based n8n
workflow continue to work correctly.

## Setup

### 1. Supabase

1. Create a new Supabase project
2. Run the schema SQL (see `/sql` if included, or set up tables per the schema above)
3. Enable Realtime on the `leads` and `interactions` tables
4. Create an admin user under **Authentication > Users**
5. Note your Project URL and `anon` key (for the app) and `service_role` key (for n8n only — never expose client-side)

### 2. n8n

1. Set up a Webhook trigger to receive Tally form submissions
2. Add a Code node to normalize Tally's dropdown field format into flat values
3. Add a Supabase node (Insert) to write new leads
4. Build a separate scheduled workflow: Supabase (Get rows, filtered on `next_follow_up_at`, `status`, `follow_up_count`) → Email node → Supabase (Update) → Supabase (Insert into `interactions`)

### 3. Flutter app

1. Clone this repo
2. Create a `.env` file at the project root:
   ```
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run:
   ```bash
   flutter run
   ```

**Note:** `.env` is git-ignored. Use `.env.example` as a template for required variables.

### Building a release APK

```bash
flutter build apk --release
```

Make sure `android/app/src/main/AndroidManifest.xml` includes:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```
(Required for release builds — debug builds get network access automatically, but release builds need it declared explicitly.)

## Roadmap

- [ ] Reconnect WhatsApp as a follow-up channel once WhatsApp Business API access is restored
- [ ] Search and filtering on the dashboard
- [ ] Multi-user support (team assignment via `assigned_to`)
- [ ] Per-client data isolation for multi-tenant use

## License

Private project — not currently licensed for reuse.