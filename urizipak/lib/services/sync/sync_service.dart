/// 데이터 동기화 계약.
///
/// [Local First 전략]
/// 모든 데이터는 우선 로컬 리포지토리에 기록된다.
/// Firebase 연동 시:
///   1) domain/repositories 인터페이스의 Firestore 구현 추가
///   2) 이 인터페이스의 FirebaseSyncService 구현 추가 (로컬 ↔ 클라우드 병합)
///   3) app/di.dart의 바인딩 교체
/// 서비스/UI 코드는 수정하지 않는다.
library;

abstract interface class SyncService {
  /// 클라우드(커플 상대방)와 연결되어 있는지.
  bool get isCloudConnected;

  /// 로컬 변경분을 클라우드와 동기화한다.
  Future<void> synchronize();
}

/// MVP 구현: 로컬 전용. 동기화는 아무 것도 하지 않는다.
class LocalOnlySyncService implements SyncService {
  const LocalOnlySyncService();

  @override
  bool get isCloudConnected => false;

  @override
  Future<void> synchronize() async {}
}
