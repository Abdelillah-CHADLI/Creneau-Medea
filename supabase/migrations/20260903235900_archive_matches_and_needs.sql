-- Reversible, per-user list cleanup. No game or request is deleted.
alter table public.games add column if not exists archived_at timestamptz;
alter table public.game_requests add column if not exists archived_at timestamptz;

-- Canonical values used by the app. Ensuring all of them exist prevents a
-- multi-selection such as ball + pump from being only partially persisted.
insert into public.needs (name)
values ('players'), ('opponent'), ('football'), ('pump'), ('pitch_available')
on conflict (name) do nothing;
