# Firebase 연동 가이드

우리지갑은 **Local First** 구조로 설계되어 있어, Firebase 연동은
"리포지토리 구현 추가 + `app/di.dart` 바인딩 교체"로 끝난다.
서비스 계층과 UI는 한 줄도 바뀌지 않는다.

## 1. 사전 준비

1. Firebase 콘솔에서 프로젝트 생성 (예: `urizipak`)
2. Android/iOS 앱 등록 후 설정 파일 추가
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
3. 의존성 추가
   ```bash
   flutter pub add firebase_core firebase_auth cloud_firestore
   ```
4. `main.dart`의 `AppServices.create()` 호출 전에 `Firebase.initializeApp()` 추가

## 2. Firestore 데이터 모델 (제안)

```
couples/{coupleId}
  ├─ members: [uidA, uidB]
  ├─ createdAt
  ├─ transactions/{id}     # TransactionEntry.toJson() 그대로
  ├─ goals/{id}            # SavingGoal.toJson()
  ├─ goal_contributions/{id}
  ├─ assets/{id}           # AssetItem.toJson()
  ├─ app_money_ledger/{id} # AppMoneyEntry.toJson()
  ├─ inventory (doc)       # { ownedItemIds: [...] }
  ├─ room (doc)            # RoomModel.toJson()
  └─ characters (doc)      # CharacterProfile 목록

invites/{inviteCode}
  ├─ issuerUid
  ├─ createdAt
  └─ expiresAt             # 24시간 등
```

모든 모델이 이미 `toJson`/`fromJson`을 갖고 있으므로 문서 스키마 변환이 필요 없다.

## 3. 구현해야 할 클래스

| 인터페이스 (domain/repositories) | Firebase 구현 (data/firebase/) |
|---|---|
| `TransactionRepository` | `FirestoreTransactionRepository` |
| `GoalRepository` | `FirestoreGoalRepository` |
| `AssetRepository` | `FirestoreAssetRepository` |
| `AppMoneyRepository` | `FirestoreAppMoneyRepository` |
| `InventoryRepository` | `FirestoreInventoryRepository` |
| `CharacterRepository` | `FirestoreCharacterRepository` |
| `RoomRepository` | `FirestoreRoomRepository` |
| `ShopCatalogRepository` | `FirestoreShopCatalogRepository` (카탈로그 서버화) |
| `CoupleConnector` | `FirebaseCoupleConnector` |
| `SyncService` (services/sync) | `FirebaseSyncService` |

### FirebaseCoupleConnector 동작

- `issueInviteCode()` — `invites/{code}` 문서 생성 (재발급 시 이전 코드 삭제)
- `connectWithCode(code)` — 코드 문서 검증 → `couples/{coupleId}` 생성,
  두 사용자 uid를 members에 기록 → `CoupleLink(connected)` 반환
- 잘못된/만료된 코드는 예외로 알린다 (로컬 구현의 `InvalidInviteCodeException`과 동일한 UX)

### 동기화 전략 (FirebaseSyncService)

1. 로컬 쓰기는 지금처럼 즉시 반영 (Local First 유지 — 오프라인에서도 동작)
2. `CoupleConnected` 이벤트 구독 → 최초 연결 시 로컬 데이터를 커플 문서로 업로드
3. 이후 Firestore snapshot 리스너로 상대방 변경분을 로컬 리포지토리에 병합
4. 충돌은 `updatedAt`/`createdAt` 기준 최신 우선(last-write-wins)으로 시작

## 4. di.dart 교체 예시

```dart
// 기존
final couple = CoupleService(
  repository: LocalCoupleRepository(store),
  connector: LocalCoupleConnector(),
  bus: bus,
);

// Firebase 연동 후
final couple = CoupleService(
  repository: LocalCoupleRepository(store), // 연결 상태 캐시는 로컬 유지
  connector: FirebaseCoupleConnector(firestore, auth),
  bus: bus,
);
```

## 5. 보안 규칙 (시작점)

```
match /couples/{coupleId}/{document=**} {
  allow read, write: if request.auth != null
    && request.auth.uid in resource.data.members;
}
match /invites/{code} {
  allow create: if request.auth != null;
  allow read, delete: if request.auth != null;
}
```
