/// 광고 서비스 계약 + 노출 정책.
///
/// [정책 — 절대 광고를 띄우지 않는 순간]
/// 거래 입력, 환불, 목표 등록, 커플 연결.
/// 돈을 기록하고 약속하는 순간은 우리지갑에서 가장 감정적으로 중요한
/// 순간이므로 광고로 끊지 않는다. 이 정책은 [AdPolicy]에서 코드로 강제된다.
library;

/// 광고가 노출될 수 있는 지면.
enum AdPlacement {
  transactionInput('거래 입력'),
  refund('환불'),
  goalCreate('목표 등록'),
  coupleConnect('커플 연결'),
  ledgerBrowse('가계부 목록'),
  shopBrowse('상점 둘러보기'),
  assetBrowse('자산 목록'),
  settings('설정');

  const AdPlacement(this.label);

  final String label;
}

class AdPolicy {
  AdPolicy._();

  /// 광고 금지 지면. 여기 포함되면 어떤 광고도 노출하지 않는다.
  static const Set<AdPlacement> blocked = {
    AdPlacement.transactionInput,
    AdPlacement.refund,
    AdPlacement.goalCreate,
    AdPlacement.coupleConnect,
  };

  static bool isAllowed(AdPlacement placement) => !blocked.contains(placement);
}

/// 광고 SDK 추상화. AdMob 연동 시 GoogleAdService 구현을 추가하고
/// app/di.dart에서 교체한다. 모든 구현은 [AdPolicy]를 반드시 통과시켜야 한다.
abstract interface class AdService {
  /// 전면 광고 노출 시도. 정책상 금지 지면이면 아무 것도 하지 않는다.
  Future<void> maybeShowInterstitial(AdPlacement placement);

  /// 배너 노출 가능 여부 (UI가 배너 슬롯을 그릴지 결정할 때 사용).
  bool canShowBanner(AdPlacement placement);
}

/// MVP 구현: 광고 없음. AdMob 붙이기 전까지 사용.
class NoopAdService implements AdService {
  const NoopAdService();

  @override
  Future<void> maybeShowInterstitial(AdPlacement placement) async {
    // 정책 검증 훅만 유지한다. 실제 구현체도 동일한 가드로 시작해야 한다.
    if (!AdPolicy.isAllowed(placement)) return;
  }

  @override
  bool canShowBanner(AdPlacement placement) => false;
}
