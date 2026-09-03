-- Apply this migration to an existing Supabase project after the base schema.
-- It prevents users from browsing every profile/phone number while preserving
-- the organizer workflow used by the app's player management screen.

drop policy if exists "users_select" on public.users;

create policy "users_select" on public.users for select using (
  auth.uid() = id
  or exists (
    select 1
    from public.game_requests request
    join public.games game on game.id = request.game_id
    where request.user_id = users.id and game.user_id = auth.uid()
  )
);
