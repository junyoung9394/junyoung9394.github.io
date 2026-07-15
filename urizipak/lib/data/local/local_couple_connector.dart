import 'dart:math';

import '../../domain/models/couple.dart';
import '../../domain/repositories/repositories.dart';

/// 초대 코드 형식이 잘못되었을 때.
class InvalidInviteCodeException implements Exception {
  const InvalidInviteCodeException(this.code);

  final String code;
}

/// MVP용 로컬 커플 연결 시뮬레이션.
///
/// 서버가 없으므로 코드 형식(영문 대문자/숫자 6자리)만 검증하고
/// 즉시 연결된 것으로 처리한다. 실제 상대방 검증/매칭은
/// Firebase 구현(FirebaseCoupleConnector)이 담당한다 — docs/FIREBASE.md 참고.
class LocalCoupleConnector implements CoupleConnector {
  LocalCoupleConnector({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const String _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const int codeLength = 6;

  static final RegExp _codePattern = RegExp('^[A-Z0-9]{$codeLength}\$');

  @override
  Future<String> issueInviteCode() async {
    return List.generate(
      codeLength,
      (_) => _codeChars[_random.nextInt(_codeChars.length)],
    ).join();
  }

  @override
  Future<CoupleLink> connectWithCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (!_codePattern.hasMatch(normalized)) {
      throw InvalidInviteCodeException(code);
    }
    return CoupleLink(
      status: CoupleStatus.connected,
      coupleId: 'local-$normalized',
      connectedAt: DateTime.now(),
    );
  }

  @override
  Future<void> disconnect() async {}
}
