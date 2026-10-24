// 캐시 버전 — 배포 시 콘텐츠가 바뀌면 숫자를 올리면 됨 (이전 캐시는 activate에서 삭제)
const CACHE = 'yeonbong-v2';
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
  '/js/tax.js',
  '/js/adsense.js',
  '/js/share.js',
  '/js/fortune-data.js',
  '/site-analytics.js',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
];

self.addEventListener('install', e => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)));
});

self.addEventListener('activate', e =>
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  )
);

// 네트워크 우선 — 최신 요율·콘텐츠를 보여주고, 오프라인일 때만 캐시 사용
self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== location.origin) return;
  e.respondWith(
    fetch(req)
      .then(res => {
        if (res.ok) {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(req, copy));
        }
        return res;
      })
      .catch(() => caches.match(req, { ignoreSearch: true }))
  );
});
