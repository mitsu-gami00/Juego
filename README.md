# Chester: UNDERTAIL

Juego de rol en el navegador inspirado en Undertale y Deltarune: crea tu animal, elige rol y subclase, y juega en grupos de hasta 4 o en duelos PvP.

## Jugar
Abre la página de GitHub Pages de este repositorio. Controles: flechas para moverte, Z aceptar, X cancelar/correr, C menú, T chat. En celular aparece un control táctil.

## Modo en línea (Supabase)
GitHub Pages solo sirve archivos, así que el multijugador usa **Supabase Realtime** como puente. No necesita tablas ni SQL.

1. Crea una cuenta gratis en https://supabase.com y un proyecto nuevo.
2. Ve a **Project Settings → API** y copia la **Project URL** y la clave **publishable** (o **anon public**). Nunca uses la clave secreta.
3. Edita `config.js` en este repositorio y pégalas en `supabaseUrl` y `supabaseKey`.
4. Guarda (commit). En un minuto, la página mostrará **● EN LÍNEA** en la pantalla de título.

Si `config.js` está vacío, el juego funciona en modo solitario.

## Guardado
La partida se guarda en el navegador de cada jugador (localStorage).

## Límites del plan gratis de Supabase
Pensado para un curso o grupo de amigos (decenas de jugadores a la vez). Las posiciones se envían como mensajes ligeros y la "presencia" solo cuando cambia algo importante, para no pasarse de la cuota.
