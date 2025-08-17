
const CACHE = 'lafc-auto-rtcfg-v1';
const ASSETS = ['./','./index.html','./styles.css','./app.js','./manifest.json','./robots.txt'];
self.addEventListener('install', e=> e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS))));
self.addEventListener('activate', e=> self.clients.claim());
self.addEventListener('fetch', e=>{
  e.respondWith(caches.match(e.request).then(r=> r || fetch(e.request)));
});
