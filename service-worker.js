const CACHE = 'yeonbong-v1';
const ASSETS = [
  '/',
  '/index.html',
  '/salary.html',
  '/percentile.html',
  '/severance.html',
  '/minimum-wage.html',
  '/fortune.html',
  '/quiz.html',
  '/styles.css',
  '/js/tax2026.js',
  '/js/adsense.js',
  '/js/share.js',
  '/js/fortune-data.js',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
];

self.addEventListener('install', e =>
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)))
);

self.addEventListener('activate', () => self.clients.claim());

self.addEventListener('fetch', e => {
  // AdSense, Google APIs는 항상 네트워크에서 로드
  if (e.request.url.includes('googlesyndication') || e.request.url.includes('googletagservices')) return;
  e.respondWith(caches.match(e.request).then(r => r || fetch(e.request)));
});
