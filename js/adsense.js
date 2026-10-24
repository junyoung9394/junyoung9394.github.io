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

// 기본 슬롯: 같은 계정의 반응형 디스플레이 광고 단위 (welfare 사이트와 공용)
// 사이트별 성과를 따로 보려면 AdSense에서 새 광고 단위를 만들어 이 값만 교체
const DEFAULT_SLOT = '4593096138';
function insertAd(containerId, slotId = DEFAULT_SLOT) {
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
