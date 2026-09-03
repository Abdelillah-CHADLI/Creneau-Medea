-- Match organizers are visible to signed-in players so match details can show
-- their name, position, rating and contact information. Requester profiles
-- remain visible only to the organizer handling that request.
drop policy if exists "users_select" on public.users;
create policy "users_select" on public.users for select using (
  auth.uid() = id
  or exists (
    select 1
    from public.game_requests request
    join public.games game on game.id = request.game_id
    where request.user_id = users.id and game.user_id = auth.uid()
  )
  or (
    auth.uid() is not null
    and exists (select 1 from public.games game where game.user_id = users.id)
  )
);

-- A rating must be submitted by the actual organizer for an accepted player
-- belonging to that exact match. The unique request key prevents duplicates.
drop policy if exists "player_ratings_insert" on public.player_ratings;
create policy "player_ratings_insert" on public.player_ratings for insert with check (
  auth.uid() = organizer_id
  and exists (
    select 1
    from public.game_requests request
    join public.games game on game.id = request.game_id
    where request.id = player_ratings.game_request_id
      and request.game_id = player_ratings.game_id
      and request.user_id = player_ratings.player_id
      and request.status = 'accepted'
      and game.user_id = auth.uid()
  )
);

-- Keep the denormalized profile score correct after any rating change.
create or replace function public.refresh_player_rating()
returns trigger language plpgsql security definer set search_path = public as $$
declare target_player uuid;
begin
  if tg_op = 'DELETE' then
    target_player := old.player_id;
  else
    target_player := new.player_id;
  end if;
  update public.users
  set rating = coalesce((select round(avg(rating)::numeric, 2) from public.player_ratings where player_id = target_player), 0),
      rating_count = (select count(*) from public.player_ratings where player_id = target_player),
      updated_at = now()
  where id = target_player;
  return null;
end;
$$;

drop trigger if exists refresh_player_rating_after_change on public.player_ratings;
create trigger refresh_player_rating_after_change
after insert or update or delete on public.player_ratings
for each row execute function public.refresh_player_rating();

update public.users profile
set rating = stats.average_rating,
    rating_count = stats.total_ratings,
    updated_at = now()
from (
  select player_id, round(avg(rating)::numeric, 2) as average_rating, count(*) as total_ratings
  from public.player_ratings
  group by player_id
) stats
where profile.id = stats.player_id;

insert into public.needs (name) values ('pump') on conflict (name) do nothing;
insert into public.needs (name) values ('pitch_available') on conflict (name) do nothing;

-- Expose only aggregate capacity numbers. Direct request rows stay protected by
-- RLS, while discovery cards can still display an accurate accepted count.
create or replace function public.accepted_game_counts(game_ids bigint[])
returns table(game_id bigint, accepted_count bigint)
language sql stable security definer set search_path = public as $$
  select game.id, count(request.id)
  from public.games game
  left join public.game_requests request
    on request.game_id = game.id and request.status = 'accepted'
  where game.id = any(game_ids)
  group by game.id;
$$;
revoke all on function public.accepted_game_counts(bigint[]) from public;
grant execute on function public.accepted_game_counts(bigint[]) to authenticated;
