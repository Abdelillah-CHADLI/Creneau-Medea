# Créneau Médea

A football pitch / match booking app for Médea (RTL Arabic UI).

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```
## Running the app (offline, no backend required)

The app runs standalone out of the box. When a Supabase project is **not** configured,
it uses a seeded in-memory `LocalStore` so every screen works:

- Sign in / sign up accept any email/password.
- Home & Explore list seeded games.
- Creating a request adds a real game locally.
- My Matches shows organized/joined games; the organizer can accept/reject requests
  and toggle attendance.

```bash
flutter pub get
flutter run
```

## Connecting Supabase (optional, for real multi-user data)

1. Create a project at https://supabase.com.
2. Open **SQL Editor** and run `supabase/schema.sql` (tables, enums, RLS).
3. Run the files in `supabase/migrations` in filename order, including `20260903_profiles_and_ratings.sql`.
4. Optional: run `supabase/seed.sql` for sample pitches and need types.
5. In **Authentication > Providers > Email**, keep Email enabled and turn **Confirm email** off. This creates accounts immediately, as intended by this app.
6. In **Authentication > URL Configuration**, set your production Site URL and add it to Redirect URLs. Password recovery still uses the email address; it does not require confirmation at sign-up.
7. Grab your project URL and the public **anon** key from **Settings > API**.
8. Run the app pointing at the project:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

When configured, the app:
- Signs in/up through **Supabase Auth** (`users.id` is the Auth `uuid`).
- Reads/writes `games`, `game_requests`, `needs`, `game_needs`, `pitches`,
  `users`, and `player_ratings` via PostgREST, guarded by RLS.

## Production checklist

- `dz.creneaumedea.app` is the Android application id in this repository. Confirm it is available in Google Play, or replace it with a domain you own before creating a release.
- Create an Android upload keystore and configure a release signing config; never publish an APK/AAB signed with the debug key.
- On an existing Supabase project, run both SQL migration files in chronological order. New projects must run `schema.sql` first.
- Device reminders are local. The in-app inbox is backed by Supabase database triggers and covers join requests, decisions, and cancellations.

## Schema

The relevant tables live under `supabase/schema.sql`. Field/vocabulary notes:

| Model         | Table            | Notes                                        |
|---------------|------------------|----------------------------------------------|
| `User`        | `users`          | `id uuid` links to `auth.users(id)`          |
| `Game`        | `games`          | organizer = `user_id` uuid                   |
| `Request`     | `game_requests`  | `status`/`attendance_status` enums           |
| `Pitch`       | `pitches`        | seeded samples                               |
| `Need`/`GameNeed` | `needs`, `game_needs` | request needs, e.g. players, ball, pump |
