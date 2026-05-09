// AdSense lazy loader — 첫 사용자 인터랙션 후 로드 (Core Web Vitals 보호)
const PUBLISHER_ID = 'ca-pub-8518556382646891';

let loaded = false;
function loadAdSense() {
  if (loaded) return;
  loaded = true;
  const s = document.createElement('script');
  s.async = true;
  s.crossOrigin = 'anonymous';
  s.src = `https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${PUBLISHER_ID}`;
  document.head.appendChild(s);
}

// 슬롯 ID는 AdSense 대시보드에서 광고 단위 생성 후 교체
function insertAd(containerId, slotId = '0000000000') {
  const container = document.getElementById(containerId);
  if (!container) return;
  const ins = document.createElement('ins');
  ins.className = 'adsbygoogle';
  ins.style.cssText = 'display:block;text-align:center;margin:20px 0';
  ins.dataset.adClient = PUBLISHER_ID;
  ins.dataset.adSlot = slotId;
  ins.dataset.adFormat = 'auto';
  ins.dataset.fullWidthResponsive = 'true';
  container.appendChild(ins);
  (window.adsbygoogle = window.adsbygoogle || []).push({});
}

['scroll', 'click', 'touchstart', 'keydown'].forEach(evt =>
  window.addEventListener(evt, loadAdSense, { once: true, passive: true })
);
