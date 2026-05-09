// 카카오톡 / URL 공유 유틸리티
// Kakao SDK는 각 HTML 페이지에서 <script>로 별도 로드

function shareKakao({ title, description, imageUrl, linkUrl }) {
  if (!window.Kakao || !Kakao.isInitialized()) {
    // Kakao SDK 미초기화 시 URL 복사로 폴백
    copyToClipboard(linkUrl || location.href);
    alert('링크가 복사됐습니다. 카카오톡에 붙여넣기 하세요!');
    return;
  }
  Kakao.Share.sendDefault({
    objectType: 'feed',
    content: {
      title,
      description,
      imageUrl: imageUrl || 'https://junyoung9394.github.io/icons/icon-512.png',
      link: { mobileWebUrl: linkUrl || location.href, webUrl: linkUrl || location.href },
    },
    buttons: [{ title: '계산해보기', link: { mobileWebUrl: linkUrl || location.href, webUrl: linkUrl || location.href } }],
  });
}

function copyToClipboard(text) {
  if (navigator.clipboard) {
    navigator.clipboard.writeText(text).catch(() => _fallbackCopy(text));
  } else {
    _fallbackCopy(text);
  }
}

function _fallbackCopy(text) {
  const ta = document.createElement('textarea');
  ta.value = text;
  ta.style.position = 'fixed';
  ta.style.opacity = '0';
  document.body.appendChild(ta);
  ta.select();
  document.execCommand('copy');
  document.body.removeChild(ta);
}

function shareCurrentPage(title, description) {
  const url = location.href;
  if (navigator.share) {
    navigator.share({ title, text: description, url }).catch(() => {});
  } else {
    copyToClipboard(url);
    alert('링크가 복사됐습니다!');
  }
}
