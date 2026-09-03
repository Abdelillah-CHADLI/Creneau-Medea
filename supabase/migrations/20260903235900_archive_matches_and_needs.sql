-- Reversible, per-user list cleanup. No game or request is deleted.
alter table public.games add column if not exists archived_at timestamptz;
alter table public.game_requests add column if not exists archived_at timestamptz;

-- Canonical values used by the app. Ensuring all of them exist prevents a
-- multi-selection such as ball + pump from being only partially persisted.
insert into public.needs (name)
values ('players'), ('opponent'), ('football'), ('pump'), ('pitch_available')
on conflict (name) do nothing;

-- Preserve associations created with the original Arabic seed values, then
-- remove those aliases so every client sees one consistent vocabulary.
insert into public.game_needs (game_id, need_id, quantity)
select link.game_id, canonical.id, link.quantity
from public.game_needs link
join public.needs legacy on legacy.id = link.need_id
join public.needs canonical on canonical.name = case legacy.name
  when 'الكرة مطلوبة' then 'football'
  when 'لاعبون إضافيون' then 'players'
  when 'المضخة مطلوبة' then 'pump'
  when 'فريق خصم' then 'opponent'
end
where legacy.name in ('الكرة مطلوبة', 'لاعبون إضافيون', 'المضخة مطلوبة', 'فريق خصم')
on conflict (game_id, need_id) do update
set quantity = greatest(game_needs.quantity, excluded.quantity);

delete from public.game_needs link
using public.needs legacy
where link.need_id = legacy.id
  and legacy.name in ('الكرة مطلوبة', 'لاعبون إضافيون', 'المضخة مطلوبة', 'فريق خصم');

delete from public.needs
where name in ('الكرة مطلوبة', 'لاعبون إضافيون', 'المضخة مطلوبة', 'فريق خصم');
