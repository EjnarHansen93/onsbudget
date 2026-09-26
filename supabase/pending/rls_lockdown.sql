-- OnsBudget — beveiliging: enkel ingelogde leden mogen de data zien/wijzigen.
-- NOG NIET UITGEVOERD. Pas uitvoeren NADAT:
--   1. de nieuwe index.html (met inlogscherm) live staat op GitHub Pages;
--   2. beide accounts bestaan in Supabase (Authentication → Users → Add user, "Auto confirm");
--   3. de juiste e-mailadressen hieronder in budget_members staan.
-- Vanaf dan werkt de anon key alleen nog om in te loggen.

create table if not exists public.budget_members (
  email text primary key
);
alter table public.budget_members enable row level security;  -- geen policies: onleesbaar voor de app

insert into public.budget_members (email) values
  ('ejnarh@hotmail.com'),
  ('SHAUNI_EMAIL_HIER')
on conflict do nothing;

create or replace function public.is_budget_member()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.budget_members m
    where m.email = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke execute on function public.is_budget_member() from public, anon;
grant execute on function public.is_budget_member() to authenticated;

drop policy if exists budget_profiles_all     on public.budget_profiles;
drop policy if exists budget_savings_all      on public.budget_savings;
drop policy if exists budget_recurring_all    on public.budget_recurring;
drop policy if exists budget_transactions_all on public.budget_transactions;
drop policy if exists budget_notes_all        on public.budget_notes;

create policy budget_profiles_members     on public.budget_profiles     for all to authenticated using (public.is_budget_member()) with check (public.is_budget_member());
create policy budget_savings_members      on public.budget_savings      for all to authenticated using (public.is_budget_member()) with check (public.is_budget_member());
create policy budget_recurring_members    on public.budget_recurring    for all to authenticated using (public.is_budget_member()) with check (public.is_budget_member());
create policy budget_transactions_members on public.budget_transactions for all to authenticated using (public.is_budget_member()) with check (public.is_budget_member());
create policy budget_notes_members        on public.budget_notes        for all to authenticated using (public.is_budget_member()) with check (public.is_budget_member());
