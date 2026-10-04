# Arma index.html de TEAM C a partir del código de la app de claude.ai (index.src.html):
# reemplaza la base de datos de claude.ai por Supabase, agrega login, marca TEAM C y PWA.
param([string]$url = "SUPABASE_URL", [string]$key = "SUPABASE_ANON_KEY", [string]$appUrl = "https://clubdelacro1.github.io/team-c/")
$ErrorActionPreference = "Stop"
$d = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = [IO.File]::ReadAllText("$d\index.src.html", [Text.Encoding]::UTF8)
function Cambiar([string]$old, [string]$new) { if (-not $script:src.Contains($old)) { throw "No encontrado: $($old.Substring(0, [Math]::Min(80, $old.Length)))" }; $script:src = $script:src.Replace($old, $new) }

# --- documento completo + PWA ---
$head = @"
<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#5b3a22">
<meta name="description" content="TEAM C: recetario, menú, compras y presupuesto para la cocina de eventos.">
<link rel="manifest" href="manifest.json">
<link rel="icon" type="image/png" href="img/icono-192.png">
<link rel="apple-touch-icon" href="img/icono-192.png">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="TEAM C">
<title>TEAM C</title>
"@
Cambiar '<title>Cocina de Eventos</title>' $head
Cambiar '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Sora:wght@600;700&family=Nunito+Sans:opsz,wght@6..12,400;6..12,600;6..12,700&family=IBM+Plex+Mono:wght@500&display=swap">' '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Montserrat:wght@600;700;800&family=Nunito+Sans:opsz,wght@6..12,400;6..12,600;6..12,700&family=IBM+Plex+Mono:wght@500&display=swap">'
Cambiar '</style>' (@'
.brand{display:flex;align-items:center;gap:10px}
.brand img{width:40px;height:40px;border-radius:10px}
.brand h1{font-family:"Montserrat",var(--display);font-weight:800;letter-spacing:.04em}
.brand h1 span{color:var(--gold)}
.authbar{margin-left:auto;display:flex;align-items:center;gap:8px;font-size:12px;color:var(--muted)}
.authbar .who{max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.ro{background:var(--warn-soft);color:var(--warn);border-radius:10px;padding:8px 12px;font-size:13px}
html,body{margin:0}
</style>
</head>
<body>
'@)
# --- colores TEAM C: marrón y dorado ---
Cambiar '--accent:#5B3A8C; --accent-ink:#FFFFFF; --accent-soft:#ECE5F6;' '--accent:#6B4226; --accent-ink:#FFFFFF; --accent-soft:#F3E7DC; --gold:#C98A2E;'
Cambiar '--bg:#F4F2F7; --panel:#FFFFFF; --ink:#1D1726; --muted:#675F73; --line:#E1DCE8;' '--bg:#F7F2EC; --panel:#FFFFFF; --ink:#2A1C12; --muted:#6F5E50; --line:#E8DCCF;'
$darkOld = @'
  --bg:#141019; --panel:#1E1826; --ink:#ECE7F3; --muted:#A79FB3; --line:#332B3E;
  --accent:#B79BE8; --accent-ink:#1A1222; --accent-soft:#2D2340;
'@
$darkNew = @'
  --bg:#1A120C; --panel:#251A12; --ink:#F3E9DE; --muted:#B5A392; --line:#3D2D21;
  --accent:#E0A15A; --accent-ink:#1A120C; --accent-soft:#3A2817; --gold:#F2B45A;
'@
Cambiar $darkOld $darkNew
# --- encabezado con logo y sesión ---
Cambiar '      <h1>Cocina de Eventos</h1>' '      <div class="brand"><img src="img/icono-192.png" alt=""><h1>TEAM <span>C</span></h1></div><div class="authbar" id="authbar"></div>'
Cambiar '</nav>' '</nav>'
$fin = $src.LastIndexOf("</script>")
$src = $src.Substring(0, $fin) + "</script>`n<script>if ('serviceWorker' in navigator) addEventListener('load', () => navigator.serviceWorker.register('sw.js').catch(() => {}));</script>`n</body>`n</html>`n"
# --- link propio de cada evento ---
Cambiar 'const APP_URL = "https://claude.ai/artifact/RQbN2iKi9EotK4FefWScDe";' "const APP_URL = `"$appUrl`";"
# --- Supabase en vez de la base de claude.ai ---
Cambiar '<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>' (@'
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
'@)
$adapter = @"
  // ---------- conexión a Supabase (misma forma que usaba la app: colecciones de documentos) ----------
  const SB = window.supabase.createClient("$url", "$key", { db: { schema: "teamc" } });
  let sesion = null;
  function pedirLogin(){
    const el = sheet(``<h2>Entrar para editar</h2>
      <p class="note">Te mandamos un link a tu mail. Solo pueden editar los mails autorizados del equipo.</p>
      <div class="field"><label for="lgMail">Tu mail</label><input id="lgMail" type="email" autocomplete="email" placeholder="tu@mail.com"></div>
      <div class="actions"><button class="btn ghost" data-close>Cancelar</button><button class="btn" id="lgOk">Mandarme el link</button></div>``);
    `$("lgMail").focus();
    el.querySelector("#lgOk").onclick = async () => {
      const mail = `$("lgMail").value.trim(); if (!mail) return;
      const { error } = await SB.auth.signInWithOtp({ email: mail, options: { emailRedirectTo: location.origin + location.pathname + location.hash } });
      if (error) { toast("No se pudo mandar el link. Probá de nuevo."); return; }
      closeSheet(); toast("Te mandamos el link. Revisá tu mail.");
    };
  }
  function pintarSesion(){
    const b = `$("authbar"); if (!b) return;
    if (sesion){ b.innerHTML = ``<span class="who">`${esc(sesion.user.email)}</span><button class="btn ghost sm" id="lgOut">Salir</button>``; `$("lgOut").onclick = async () => { await SB.auth.signOut(); }; }
    else { b.innerHTML = ``<button class="btn ghost sm" id="lgIn">Entrar</button>``; `$("lgIn").onclick = pedirLogin; }
  }
  const sinPermiso = () => { if (!sesion){ pedirLogin(); return Promise.reject({ code: "login" }); } return null; };
  const tablaDe = col => col;
  function crearDb(){
    const ref = (col, id) => ({
      set: async data => { const no = sinPermiso(); if (no) return no; const { error } = await SB.from(tablaDe(col)).upsert({ id, data, updated_at: new Date().toISOString() }); if (error){ toast(error.code === "42501" ? "Tu mail no tiene permiso para editar." : "No se pudo guardar."); throw error; } },
      update: async data => { const { data: fila } = await SB.from(tablaDe(col)).select("data").eq("id", id).maybeSingle(); return ref(col, id).set(Object.assign({}, fila ? fila.data : {}, data)); },
      delete: async () => { const no = sinPermiso(); if (no) return no; const { error } = await SB.from(tablaDe(col)).delete().eq("id", id); if (error){ toast("No se pudo borrar."); throw error; } },
      get: async () => { const { data: fila } = await SB.from(tablaDe(col)).select("data").eq("id", id).maybeSingle(); return { exists: !!fila, data: () => fila ? fila.data : undefined }; }
    });
    return {
      doc: path => { const [c, id] = path.split("/"); return ref(c, id); },
      collection: col => ({
        doc: id => ref(col, id || (Date.now().toString(36) + Math.random().toString(36).slice(2, 6))),
        onSnapshot: (cb, onErr) => {
          const mapa = {};
          const emitir = () => cb({ docs: Object.keys(mapa).map(id => ({ id, exists: true, data: () => mapa[id] })) });
          (async () => {
            let desde = 0;
            while (true){
              const { data, error } = await SB.from(tablaDe(col)).select("id,data").range(desde, desde + 999);
              if (error){ if (onErr) onErr(error); return; }
              data.forEach(f => { mapa[f.id] = f.data; });
              if (data.length < 1000) break; desde += 1000;
            }
            emitir();
            SB.channel("rt-" + col).on("postgres_changes", { event: "*", schema: "teamc", table: tablaDe(col) }, p => {
              if (p.eventType === "DELETE") delete mapa[p.old.id]; else mapa[p.new.id] = p.new.data;
              emitir();
            }).subscribe();
          })();
          return () => {};
        }
      })
    };
  }
  // descargas: en la web propia se bajan directo
  const descargasWeb = { save: async ({ filename, data }) => { const b = data instanceof Blob ? data : new Blob([data]); const a = document.createElement("a"); a.href = URL.createObjectURL(b); a.download = filename; document.body.appendChild(a); a.click(); setTimeout(() => { URL.revokeObjectURL(a.href); a.remove(); }, 1000); return { status: "saved" }; } };

"@
Cambiar '  // ---------- navegación ----------' ($adapter + '  // ---------- navegación ----------')
Cambiar '    db = window.claude && window.claude.use ? await window.claude.use("db") : null;' (@'
    const { data: { session } } = await SB.auth.getSession(); sesion = session; pintarSesion();
    SB.auth.onAuthStateChange((_e, s) => { sesion = s; pintarSesion(); });
    db = crearDb();
'@)
Cambiar '    downloads = await window.claude.use("downloads");' '    downloads = descargasWeb;'
Cambiar '''<div class="empty">Abrí esta app en claude.ai con tu cuenta para ver y guardar tus recetas y eventos.</div>''' '''<div class="empty">No se pudo conectar con la base de datos. Revisá tu conexión y recargá.</div>'''

[IO.File]::WriteAllText("$d\index.html", $src, (New-Object Text.UTF8Encoding($false)))
$manifest = [ordered]@{ name = "TEAM C"; short_name = "TEAM C"; description = "Cocina de eventos: recetas, menú, compras y presupuesto"; start_url = "./"; scope = "./"; display = "standalone"; background_color = "#5b3a22"; theme_color = "#5b3a22"; icons = @(@{ src = "img/icono-192.png"; sizes = "192x192"; type = "image/png" }, @{ src = "img/icono-512.png"; sizes = "512x512"; type = "image/png" }, @{ src = "img/icono-512.png"; sizes = "512x512"; type = "image/png"; purpose = "maskable" }) }
[IO.File]::WriteAllText("$d\manifest.json", ($manifest | ConvertTo-Json -Depth 5), (New-Object Text.UTF8Encoding($false)))
"index.html armado"
