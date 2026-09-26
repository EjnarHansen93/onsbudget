-- OnsBudget — databaseschema (Supabase / Postgres 17)
-- Gereconstrueerd uit het live project lkzxkovpswyllzunrqks op 2026-09-26.
-- Draai dit enkel op een NIEUW/leeg project; het live project heeft deze tabellen al.

create table if not exists public.budget_profiles (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  position    integer not null default 0,
  created_at  timestamptz not null default now()
);

create table if not exists public.budget_savings (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references public.budget_profiles(id) on delete cascade,
  name        text not null,
  position    integer not null default 0,
  created_at  timestamptz not null default now()
);

create table if not exists public.budget_recurring (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references public.budget_profiles(id) on delete cascade,
  type        text not null check (type in ('in','uit')),
  amount      numeric not null check (amount >= 0),
  category    text not null,
  description text,
  day         integer not null default 1 check (day between 1 and 31),
  active      boolean not null default true,
  start_date  date not null default current_date,
  created_at  timestamptz not null default now(),
  -- t.e.m. welke datum de app al transacties aanmaakte (verwijderde komen niet terug)
  generated_until date
);

create table if not exists public.budget_transactions (
  id           uuid primary key default gen_random_uuid(),
  profile_id   uuid not null references public.budget_profiles(id) on delete cascade,
  type         text not null check (type in ('in','uit')),
  amount       numeric not null check (amount >= 0),
  category     text not null,
  description  text,
  date         date not null default current_date,
  created_at   timestamptz not null default now(),
  savings_id   uuid references public.budget_savings(id) on delete set null,
  recurring_id uuid references public.budget_recurring(id) on delete set null
);

create table if not exists public.budget_notes (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references public.budget_profiles(id) on delete cascade,
  text        text not null,
  amount      numeric check (amount is null or amount >= 0),
  done        boolean not null default false,
  created_at  timestamptz not null default now()
);
create index if not exists idx_budget_notes_profile on public.budget_notes (profile_id, created_at);

create index if not exists idx_budget_tx_profile_date
  on public.budget_transactions (profile_id, date desc, created_at desc);
-- Voorkomt dubbele automatisch aangemaakte vaste kosten (zelfde regel, zelfde datum)
create unique index if not exists uq_tx_recurring_date
  on public.budget_transactions (recurring_id, date);

-- RLS staat aan, maar de policies laten iedereen met de anon key alles doen.
alter table public.budget_profiles     enable row level security;
alter table public.budget_savings      enable row level security;
alter table public.budget_recurring    enable row level security;
alter table public.budget_transactions enable row level security;
alter table public.budget_notes        enable row level security;

create policy budget_profiles_all     on public.budget_profiles     for all to anon, authenticated using (true) with check (true);
create policy budget_savings_all      on public.budget_savings      for all to anon, authenticated using (true) with check (true);
create policy budget_recurring_all    on public.budget_recurring    for all to anon, authenticated using (true) with check (true);
create policy budget_transactions_all on public.budget_transactions for all to anon, authenticated using (true) with check (true);
create policy budget_notes_all        on public.budget_notes        for all to anon, authenticated using (true) with check (true);

-- Realtime (beide gsm's zien wijzigingen live)
alter publication supabase_realtime add table
  public.budget_profiles, public.budget_savings, public.budget_recurring, public.budget_transactions, public.budget_notes;

-- Startprofielen (enkel voor een nieuw project)
-- insert into public.budget_profiles (name, position) values
--   ('Gezamenlijk',0), ('Shauni privé',1), ('Rekening 3',2);
