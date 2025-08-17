
# LAFC 자동 최신화 — 최종 패키지 (FREE 플랜)

## 1) Cloudflare Worker
- Dashboard → Workers & Pages → Create Worker → 편집기에 `worker.js` 전체 붙여넣기
- Settings → Variables:
  - **Secret** `API_FOOTBALL_KEY` = (대시보드 API Keys의 키 값)
  - **Text** `API_FOOTBALL_HOST` = `v3.football.api-sports.io`
  - **Text** `LAFC_TEAM_ID` = `1609`
  - **Text** `MLS_LEAGUE_ID` = `253`
- Deploy 후, 발급된 `https://xxxx.workers.dev` 주소를 복사

## 2) 프런트 (GitHub Pages)
- `config.json`에서 `apiBase`를 위 워커 주소로 바꾼 뒤
- 리포 `junyoung9394.github.io` **루트**에 모든 파일 업로드
- 1분 후 접속 → 상단 **새로고침** 버튼

## 3) 특징
- 큰 글씨/큰 버튼, **KST/LA 현지** 시각 동시 표기, **한글 팀명**
- 탭: 일정/결과 · 라인업 · 선수단
- 무료 플랜 절약을 위해 워커가 응답을 5~10분 캐시
- 경기 시간대엔 **LIVE** 뱃지(간이)

## 4) 문제 해결
- 빈 화면 → 브라우저 콘솔 확인 → `config.json.apiBase` 올바른지 확인
- CORS → 워커는 `Access-Control-Allow-Origin: *` 포함
- 캐시 변경 적용 → `service-worker.js`의 버전을 `v2`로 올려 커밋

## 5) 보안
- 키는 **반드시 Worker의 Secret**으로 저장하세요. 프런트에 넣지 마세요.
