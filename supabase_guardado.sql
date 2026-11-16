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
