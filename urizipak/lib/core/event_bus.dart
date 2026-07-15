import 'dart:async';

/// 앱 내부에서 모듈(서비스) 간 통신에 사용하는 이벤트의 최상위 타입.
///
/// 우리지갑의 모듈들은 서로를 직접 참조하지 않는다.
/// 대신 각 서비스가 자신에게 의미 있는 사건을 [AppEventBus]에 발행하고,
/// 관심 있는 서비스가 구독해서 반응한다.
///
/// 예) 거래 저장(TransactionService) → [TransactionRecorded] 발행
///     → RewardService가 구독해 첫 거래 보상 지급 → [RewardGranted] 발행
///     → CharacterManager가 구독해 캐릭터를 celebrate 상태로 전환
abstract class AppEvent {
  const AppEvent();
}

/// 거래가 기록되었다.
class TransactionRecorded extends AppEvent {
  const TransactionRecorded({
    required this.transactionId,
    required this.isFirst,
  });

  final String transactionId;
  final bool isFirst;
}

/// 목표가 새로 등록되었다.
class GoalCreated extends AppEvent {
  const GoalCreated({required this.goalId, required this.isFirst});

  final String goalId;
  final bool isFirst;
}

/// 목표에 저축(불입)이 기록되었다.
class GoalContributionAdded extends AppEvent {
  const GoalContributionAdded({required this.goalId, required this.amount});

  final String goalId;
  final int amount;
}

/// 목표 금액을 달성했다.
class GoalAchieved extends AppEvent {
  const GoalAchieved({required this.goalId});

  final String goalId;
}

/// AppMoney 보상이 지급되었다.
class RewardGranted extends AppEvent {
  const RewardGranted({
    required this.rewardId,
    required this.amount,
    required this.label,
  });

  final String rewardId;
  final int amount;
  final String label;
}

/// 상점에서 아이템을 구매했다.
class ItemPurchased extends AppEvent {
  const ItemPurchased({required this.itemId});

  final String itemId;
}

/// 방(우리 공간) 구성이 변경되었다.
class RoomUpdated extends AppEvent {
  const RoomUpdated();
}

/// 커플 연결이 완료되었다.
class CoupleConnected extends AppEvent {
  const CoupleConnected({required this.coupleId});

  final String coupleId;
}

/// 앱 테마가 변경되었다.
///
/// 지금은 ThemeData만 바뀌지만, 향후 집/버튼/캐릭터 의상/가구/배경 스킨이
/// 이 이벤트를 구독해 함께 바뀐다. (CharacterManager, RoomService가 이미 구독 중)
class ThemeChanged extends AppEvent {
  const ThemeChanged({required this.themeId});

  final String themeId;
}

/// 간단한 브로드캐스트 이벤트 버스.
///
/// 서비스들은 생성자에서 이 버스만 주입받으며, 서로의 구현을 알지 못한다.
class AppEventBus {
  final StreamController<AppEvent> _controller = StreamController.broadcast();

  /// 전체 이벤트 스트림.
  Stream<AppEvent> get stream => _controller.stream;

  /// 특정 타입의 이벤트만 구독한다.
  Stream<T> on<T extends AppEvent>() => stream.where((e) => e is T).cast<T>();

  void publish(AppEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
