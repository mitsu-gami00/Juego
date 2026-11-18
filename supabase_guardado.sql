-- CodeFeelStrong · guardado en la nube
-- Pega todo esto en Supabase > SQL Editor > New query y pulsa "Run". Solo hay que hacerlo una vez.
-- La tabla queda cerrada: el juego solo puede leer o escribir a través de las tres funciones de abajo,
-- y solo conociendo el código de cuenta (20 caracteres aleatorios que funcionan como contraseña).

create table if not exists public.cfs_saves(
  uid text not null,
  k   text not null,
  v   text not null,
  t   timestamptz not null default now(),
  primary key (uid, k)
);
alter table public.cfs_saves enable row level security;
revoke all on public.cfs_saves from anon, authenticated;

create or replace function public.cfs_get(p_uid text, p_k text) returns text
language sql security definer set search_path = public as $$
  select v from public.cfs_saves where uid = p_uid and k = p_k
$$;

create or replace function public.cfs_put(p_uid text, p_k text, p_v text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if length(p_uid) < 16 or length(p_uid) > 40 or length(p_k) > 20 or length(p_v) > 400000 then
    raise exception 'datos no válidos';
  end if;
  insert into public.cfs_saves(uid, k, v, t) values (p_uid, p_k, p_v, now())
  on conflict (uid, k) do update set v = excluded.v, t = now();
end $$;

create or replace function public.cfs_del(p_uid text, p_k text) returns void
language sql security definer set search_path = public as $$
  delete from public.cfs_saves where uid = p_uid and k = p_k
$$;

revoke all on function public.cfs_get(text, text), public.cfs_put(text, text, text), public.cfs_del(text, text) from public;
grant execute on function public.cfs_get(text, text), public.cfs_put(text, text, text), public.cfs_del(text, text) to anon, authenticated;

-- =====================================================================
-- CLASIFICACIÓN DE LA ARENA (nuevo). Si ya habías ejecutado lo de arriba,
-- basta con ejecutar desde aquí hacia abajo. No pasa nada si lo ejecutas todo de nuevo.
create table if not exists public.cfs_rank(
  id  text primary key,          -- md5 del código de cuenta: nadie ve el código real
  n   text not null,
  e   int  not null default 1000,
  w   int  not null default 0,
  l   int  not null default 0,
  ro  text,
  t   timestamptz not null default now()
);
alter table public.cfs_rank enable row level security;
revoke all on public.cfs_rank from anon, authenticated;

create or replace function public.cfs_rank_put(p_code text, p_n text, p_e int, p_w int, p_l int, p_ro text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if length(p_code) < 16 or length(p_code) > 40 then raise exception 'datos no válidos'; end if;
  insert into public.cfs_rank(id, n, e, w, l, ro, t)
  values (md5(p_code), left(coalesce(p_n,'?'),12), greatest(100, least(p_e, 4000)), greatest(0, p_w), greatest(0, p_l), left(coalesce(p_ro,''),12), now())
  on conflict (id) do update set n = excluded.n, e = excluded.e, w = excluded.w, l = excluded.l, ro = excluded.ro, t = now();
end $$;

create or replace function public.cfs_rank_top() returns table(n text, e int, w int, l int, ro text)
language sql security definer set search_path = public as $$
  select n, e, w, l, ro from public.cfs_rank order by e desc, t asc limit 25
$$;

revoke all on function public.cfs_rank_put(text, text, int, int, int, text), public.cfs_rank_top() from public;
grant execute on function public.cfs_rank_put(text, text, int, int, int, text), public.cfs_rank_top() to anon, authenticated;
