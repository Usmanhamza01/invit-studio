-- ═══════════════════════════════════════════════════════════
--  INVIT'STUDIO — Schéma Supabase
--  À exécuter dans : Supabase → SQL Editor → New query
-- ═══════════════════════════════════════════════════════════

-- Table des invitations
create table if not exists public.invitations (
  id          uuid primary key default gen_random_uuid(),
  slug        text unique not null,          -- ex: "aissatou-moussa"
  data        jsonb not null,                -- toutes les infos du mariage
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- Index pour retrouver vite par slug
create index if not exists invitations_slug_idx on public.invitations (slug);

-- Activer la sécurité (RLS)
alter table public.invitations enable row level security;

-- ─── POLITIQUES D'ACCÈS ───────────────────────────────────
-- 1) N'IMPORTE QUI peut LIRE une invitation (les invités ouvrent le lien)
drop policy if exists "lecture publique" on public.invitations;
create policy "lecture publique"
  on public.invitations for select
  using (true);

-- 2) N'IMPORTE QUI peut CRÉER/MODIFIER (version simple, sans login)
--    ⚠️ Pratique pour démarrer. Si tu veux sécuriser plus tard
--    (seul toi peux publier), on ajoutera l'authentification.
drop policy if exists "ecriture publique" on public.invitations;
create policy "ecriture publique"
  on public.invitations for insert
  with check (true);

drop policy if exists "maj publique" on public.invitations;
create policy "maj publique"
  on public.invitations for update
  using (true) with check (true);

-- Fonction : met à jour updated_at automatiquement
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists trg_touch on public.invitations;
create trigger trg_touch before update on public.invitations
  for each row execute function public.touch_updated_at();

-- ═══════════════════════════════════════════════════════════
--  Fait ! La table "invitations" est prête.
-- ═══════════════════════════════════════════════════════════
