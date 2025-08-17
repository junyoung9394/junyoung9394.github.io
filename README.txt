
# LAFC 손흥민 — 엄마 전용 빠른보기 (모바일 웹, Plus 버전)

- **합법 경로만 사용**: Apple TV(MLS Season Pass), 유튜브 공식 채널 등으로 연결
- 데이터 소스 2가지 중 택1:
  1) `matches.json` 수동 업데이트 (기본)
  2) **Google Sheets CSV** 연결 — `config.json`의 `sheet_csv_url`에 퍼블리시된 CSV URL 입력

## Google Sheets CSV 연결 방법
1. 구글 스프레드시트에 아래 열을 만들고 데이터 입력:
   - `date`, `datetime`, `opponent`, `home`, `venue`, `son_expected`, `lineup`, `match_center`, `watch`, `youtube`
   - `home`, `son_expected`는 `TRUE`/`FALSE`
   - `lineup`은 `FW 손흥민 | MF ㅇㅇㅇ | DF ㅇㅇㅇ` 처럼 `|`로 구분
2. 파일 → 웹에 게시 → **시트** 선택, 형식은 **CSV**.
3. 제공된 URL을 `config.json`의 `sheet_csv_url`에 붙여넣기.
4. 저장 후 새로고침. (캐시가 남아있으면 상단 **데이터 새로고침** 버튼 클릭)

## 배포
- GitHub Pages / Vercel / Netlify / Cloudflare Pages 어디든 정적 호스팅 가능.
- PWA 지원: 휴대폰에서 열고 브라우저 메뉴 → **홈 화면에 추가**.

## 버튼 설명
- **이 경기 캘린더(.ics)**: 선택된 경기 하나를 iCal로 다운로드.
- **전체 일정 iCal**: 모든 일정이 담긴 iCal 파일 다운로드(캘린더 구독처럼 사용).

## 저작권 주의
- 불법 스트리밍 링크/재전송 금지
- 유튜브·Apple TV 등 **공식 링크**만 연결

## 파일 구성
- `index.html` — 메인 페이지
- `styles.css` — 스타일
- `app.js` — 데이터 로드/렌더링/ICS 생성, CSV 지원
- `matches.json` — 기본 데이터
- `config.json` — CSV URL 설정
- `manifest.json`, `service-worker.js` — PWA 지원
