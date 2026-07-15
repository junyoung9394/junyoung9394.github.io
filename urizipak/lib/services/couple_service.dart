import 'package:flutter/foundation.dart';

import '../core/event_bus.dart';
import '../domain/models/couple.dart';
import '../domain/repositories/repositories.dart';

/// 커플 연결 서비스.
///
/// 연결의 실제 동작(코드 발급/검증)은 [CoupleConnector]에 위임한다.
/// 연결이 완료되면 [CoupleConnected] 이벤트를 발행한다 —
/// CharacterManager가 구독해 두 캐릭터가 love 상태로 반응하고,
/// Firebase 연동 후에는 SyncService가 구독해 첫 동기화를 시작하게 된다.
class CoupleService extends ChangeNotifier {
  CoupleService({
    required this._repository,
    required this._connector,
    required this._bus,
  });

  final CoupleRepository _repository;
  final CoupleConnector _connector;
  final AppEventBus _bus;

  CoupleLink _link = CoupleLink.solo();

  Future<void> init() async {
    _link = (await _repository.load()) ?? CoupleLink.solo();
    notifyListeners();
  }

  CoupleLink get link => _link;

  CoupleStatus get status => _link.status;

  bool get isConnected => _link.status == CoupleStatus.connected;

  /// 내 초대 코드를 발급하고 상대방을 기다린다.
  Future<String> issueInviteCode() async {
    final code = await _connector.issueInviteCode();
    _link = CoupleLink(status: CoupleStatus.waiting, inviteCode: code);
    await _repository.save(_link);
    notifyListeners();
    return code;
  }

  /// 상대방의 초대 코드로 연결한다.
  ///
  /// 잘못된 코드는 [CoupleConnector] 구현이 예외로 알린다
  /// (로컬: InvalidInviteCodeException).
  Future<void> connectWithCode(String code) async {
    final connected = await _connector.connectWithCode(code);
    _link = connected;
    await _repository.save(_link);
    notifyListeners();
    _bus.publish(CoupleConnected(coupleId: connected.coupleId ?? ''));
  }

  Future<void> disconnect() async {
    await _connector.disconnect();
    _link = CoupleLink.solo();
    await _repository.save(_link);
    notifyListeners();
  }
}
