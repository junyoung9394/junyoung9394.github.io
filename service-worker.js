
const CACHE = 'lafc-mom-v2';
const ASSETS = [
  './',
  './index.html',
  './styles.css',
  './app.js',
  './matches.json',
  './config.json',
  './manifest.json'
];
self.addEventListener('install', e=>{
  e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)));
});
self.addEventListener('activate', e=>{
  e.waitUntil(self.clients.claim());
});
self.addEventListener('fetch', e=>{
  const url = new URL(e.request.url);
  if (url.pathname.endsWith('/matches.json') || url.pathname.endsWith('/config.json')) {
    e.respondWith(fetch(e.request).then(resp=>{
      const clone = resp.clone();
      caches.open(CACHE).then(c=>c.put(e.request, clone));
      return resp;
    }).catch(()=> caches.match(e.request)));
    return;
  }
  e.respondWith(caches.match(e.request).then(resp=> resp || fetch(e.request)));
});
