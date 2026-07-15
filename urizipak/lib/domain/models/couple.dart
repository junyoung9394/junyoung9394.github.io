/// 커플 연결 도메인 모델.
library;

enum CoupleStatus {
  /// 아직 연결하지 않음 (혼자 사용 중).
  solo('연결 안 됨'),

  /// 내 초대 코드를 발급하고 상대방을 기다리는 중.
  waiting('상대방을 기다리는 중'),

  /// 상대방과 연결 완료.
  connected('연결됨');

  const CoupleStatus(this.label);

  final String label;
}

class CoupleLink {
  const CoupleLink({
    required this.status,
    this.inviteCode,
    this.coupleId,
    this.connectedAt,
  });

  final CoupleStatus status;

  /// 내가 발급한 초대 코드 (waiting 상태에서 유효).
  final String? inviteCode;

  /// 연결된 커플 ID. Firebase 연동 시 Firestore couples/{coupleId} 문서 ID.
  final String? coupleId;
  final DateTime? connectedAt;

  factory CoupleLink.solo() => const CoupleLink(status: CoupleStatus.solo);

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'inviteCode': inviteCode,
    'coupleId': coupleId,
    'connectedAt': connectedAt?.toIso8601String(),
  };

  factory CoupleLink.fromJson(Map<String, dynamic> json) {
    return CoupleLink(
      status: CoupleStatus.values.byName(json['status'] as String),
      inviteCode: json['inviteCode'] as String?,
      coupleId: json['coupleId'] as String?,
      connectedAt: json['connectedAt'] != null
          ? DateTime.parse(json['connectedAt'] as String)
          : null,
    );
  }
}
