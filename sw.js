// TEAM C: guarda la "cáscara" de la app para que abra rápido e instalable en el celular.
// Los datos siempre se piden en vivo a Supabase.
const CACHE = "teamc-v7";
const BASE = ["./", "./index.html", "./manifest.json", "./img/icono-192.png", "./img/icono-512.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(BASE)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});

self.addEventListener("fetch", e => {
  const url = new URL(e.request.url);
  if (e.request.method !== "GET" || url.origin !== location.origin) return; // Supabase y CDNs van directo
  // primero la red (para ver siempre la última versión); si no hay señal, lo guardado
  e.respondWith(
    fetch(e.request).then(r => { const copia = r.clone(); caches.open(CACHE).then(c => c.put(e.request, copia)); return r; })
      .catch(() => caches.match(e.request).then(r => r || caches.match("./index.html")))
  );
});
