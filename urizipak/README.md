# 우리지갑 (urizipak)

> 함께 쓰고, 함께 모으고, 함께 키우는 **커플·부부 공동 자산관리 플랫폼**

가계부는 기능 중 하나일 뿐입니다. 사용자는 돈을 기록하는 것이 아니라
**우리 집을 키우고, 우리 캐릭터를 성장시키며, 우리 목표를 이루는 경험**을 합니다.

## 핵심 순환 구조

```
거래 기록 / 목표 등록 / 저축 / 출석 / 연속 기록
        │  (도메인 이벤트 발행)
        ▼
  RewardService ──── AppMoney 적립의 유일한 진입점
        │
        ▼
     AppMoney (원장 합계 = 잔액, 직접 += 불가)
        │
        ▼
   상점에서 아이템 구매 (InventoryService = 차감의 유일한 진입점)
        │
        ▼
   우리 공간 성장 + 캐릭터 반응 (celebrate / happy / love)
```

## 아키텍처

```
lib/
├── core/            # 이벤트 버스, 금액 포맷, ID — 의존성 없는 유틸
├── domain/
│   ├── models/      # Transaction, Goal, Asset, Character, Room, Item, AppMoney, Reward
│   └── repositories/# 데이터 접근 계약 (인터페이스)
├── data/
│   ├── local/       # Local-First 구현 (LocalStore + JSON 직렬화)
│   └── catalog/     # 더미 상점 카탈로그
├── services/        # 비즈니스 로직 (모듈). 서로 직접 의존하지 않음
│   ├── ads/         # 광고 정책 (거래입력·환불·목표등록·커플연결 = 광고 금지)
│   └── sync/        # Firebase 대비 동기화 계약
├── theme/           # 7종 테마 (Peach ~ Cocoa)
├── features/        # 화면 (UI + ViewModel)
│   └── character/   # CharacterView — 캐릭터를 그리는 유일한 위젯
└── app/             # 조립 루트 (di.dart) + MaterialApp
```

### 지켜야 할 규칙

1. **캐릭터는 `CharacterView`로만 그린다.** 화면 코드에서 `Image.asset()` 직접 사용 금지.
   렌더링 전략은 `CharacterRenderer` 인터페이스 — 현재 PNG(+이모지 폴백), 추후
   `RiveCharacterRenderer`만 추가하면 UI 수정 없이 교체된다.
2. **AppMoney는 `RewardService.grant()`로만 적립한다.** 잔액은 원장 합계로만 계산되며
   `money +=` 코드는 존재할 수 없다. 차감은 `InventoryService.purchase()`로만.
3. **모듈(서비스)끼리 직접 참조하지 않는다.** `AppEventBus`의 도메인 이벤트로 통신하고,
   배선은 `app/di.dart`(조립 루트) 한 곳에서만 한다.
4. **서비스는 리포지토리 인터페이스에만 의존한다.** Firebase 연동 = Firestore 구현 추가
   후 `di.dart` 바인딩 교체. 서비스/UI 수정 없음.
5. **한 파일 500줄 이하**, UI / ViewModel / Service / Repository / Model 분리.
6. 기존 클래스명·변수명을 이유 없이 바꾸지 않고, 기능은 삭제 대신 확장한다.

### 교체 지점 요약 (미래 확장)

| 확장 | 바꾸는 것 | 안 바꾸는 것 |
|---|---|---|
| Rive 애니메이션 | `RiveCharacterRenderer` 추가 | CharacterView 사용처 전부 |
| Firebase 동기화 | Firestore 리포지토리 + `FirebaseSyncService` | 서비스·UI 전부 |
| 국내 주식 시세 API | `StockPriceRepository` 구현 | `AssetService.refreshMarketPrices()` |
| AdMob | `GoogleAdService` (AdPolicy 필수 통과) | 광고 금지 정책 코드 |
| 상점 카탈로그 서버화 | `ShopCatalogRepository` 구현 | ShopService·상점 UI |

## 개발

```bash
flutter pub get
flutter analyze   # 0 issues 유지
flutter test      # 보상 파이프라인 통합 테스트 포함
flutter run
```

## MVP 로드맵

- [x] 1. 공동 가계부 (거래 입력/월별 요약)
- [x] 2. 공동 목표 (저축 → 보상 파이프라인)
- [x] 3. 자산 관리 (수동 입력, 순자산)
- [x] 4. 우리 공간 (Slot 방식 방 + 캐릭터)
- [x] 5. AppMoney (원장 + 보상 정책)
- [x] 6. 아이템 / 인벤토리 / 상점 (더미 카탈로그)
- [x] 7. 캐릭터 (6종 × 남녀 각자 선택, 상태 6종)
- [x] 8. 커플 연결 (초대 코드 흐름 — 로컬. 서버 검증은 Firebase 연동 시, `docs/FIREBASE.md`)
- [ ] 8-1. Firebase 실시간 동기화 (연동 절차: `docs/FIREBASE.md`)
- [ ] 9. 캐릭터/방 PNG 에셋 적용 (`assets/` 경로 규칙 참고)
- [ ] 10. Rive 애니메이션
