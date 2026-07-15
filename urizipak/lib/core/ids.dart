import 'dart:math';

/// 로컬 환경에서 충돌 가능성이 사실상 없는 간단한 ID 생성기.
///
/// Firebase 연동 시 서버가 부여하는 문서 ID로 대체될 수 있으므로
/// ID는 항상 불투명한 문자열(opaque string)로만 다룬다.
class IdGenerator {
  IdGenerator._();

  static final Random _random = Random();

  static String next() {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final rand = _random.nextInt(0x7fffffff).toRadixString(36);
    return '$time-$rand';
  }
}
