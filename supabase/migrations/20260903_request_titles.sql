-- Purpose used by pitch-availability requests. Human-readable request titles
-- continue to live in games.title.
insert into public.needs (name)
values ('pitch_available')
on conflict (name) do nothing;
