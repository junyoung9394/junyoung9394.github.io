
const CACHE = 'lafc-auto-final-v1';
const ASSETS = ['./','./index.html','./styles.css','./app.js','./config.json','./manifest.json','./robots.txt'];
self.addEventListener('install', e=> e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS))));
self.addEventListener('activate', e=> self.clients.claim());
self.addEventListener('fetch', e=>{
  const url = new URL(e.request.url);
  if (url.pathname.endsWith('/config.json')) {
    e.respondWith(fetch(e.request).catch(()=> caches.match(e.request))); return;
  }
  e.respondWith(caches.match(e.request).then(r=> r || fetch(e.request)));
});
