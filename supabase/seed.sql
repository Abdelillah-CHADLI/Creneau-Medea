-- =============================================================================
-- Créneau Médéa — Seed data (optional, run AFTER schema.sql)
-- =============================================================================

-- Core need types used across the app
insert into public.needs (name) values
  ('football'),
  ('players'),
  ('pump'),
  ('opponent'),
  ('pitch_available')
on conflict (name) do nothing;

-- A few sample pitches so the "create request" wizard has something to pick.
-- (A real user would create pitches via the admin, or these can stay.)
insert into public.pitches (name, location, condition)
select sample.name, sample.location, sample.condition
from (values
  ('ملعب سي حمدان', 'طحطوح', 'average'),
  ('ملعب زرواق', 'زرواق', 'good'),
  ('ملعب بابا', 'حي المصلى', 'bad'),
  ('ملعب ليزاكاسيا', 'الكوميساريا', 'average'),
  ('ملعب قروجة', 'حي 150 مسكن ترقوي تاكبو', 'average')
) as sample(name, location, condition)
where not exists (
  select 1 from public.pitches pitch where pitch.name = sample.name
);
