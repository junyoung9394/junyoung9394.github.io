/// 우리 공간(방) 도메인 모델.
///
/// MVP: 작은 방 하나, Slot 방식 고정 배치. 드래그 없음.
library;

/// 방 안의 고정 배치 슬롯.
enum RoomSlot {
  bed('침대', '🛏️'),
  sofa('소파', '🛋️'),
  table('테이블', '🪑'),
  plant('화분', '🪴'),
  wall('벽 장식', '🖼️'),
  rug('러그', '🟫'),
  pet('반려동물', '🐾');

  const RoomSlot(this.label, this.placeholderEmoji);

  final String label;
  final String placeholderEmoji;
}

enum RoomSeason {
  spring('봄'),
  summer('여름'),
  autumn('가을'),
  winter('겨울');

  const RoomSeason(this.label);

  final String label;

  static RoomSeason fromDate(DateTime date) {
    switch (date.month) {
      case 3 || 4 || 5:
        return RoomSeason.spring;
      case 6 || 7 || 8:
        return RoomSeason.summer;
      case 9 || 10 || 11:
        return RoomSeason.autumn;
      default:
        return RoomSeason.winter;
    }
  }
}

class RoomModel {
  const RoomModel({
    required this.themeId,
    this.wallpaperItemId,
    this.floorItemId,
    this.furniture = const {},
    this.petItemId,
    required this.season,
  });

  /// 방 전체 무드를 결정하는 테마 ID (AppThemeId.name).
  /// 향후 테마 변경 시 벽지/가구/캐릭터 의상 스킨까지 함께 바뀔 예정.
  final String themeId;

  /// 적용 중인 벽지 아이템 ID. null이면 테마 기본 벽지.
  final String? wallpaperItemId;

  /// 적용 중인 바닥 아이템 ID. null이면 테마 기본 바닥.
  final String? floorItemId;

  /// 슬롯별로 배치된 가구 아이템 ID. 비어 있는 슬롯은 키 없음.
  final Map<RoomSlot, String> furniture;

  /// 방에서 함께 사는 반려동물 아이템 ID.
  final String? petItemId;

  final RoomSeason season;

  String? itemAt(RoomSlot slot) =>
      slot == RoomSlot.pet ? petItemId : furniture[slot];

  RoomModel copyWith({
    String? themeId,
    String? wallpaperItemId,
    bool clearWallpaper = false,
    String? floorItemId,
    bool clearFloor = false,
    Map<RoomSlot, String>? furniture,
    String? petItemId,
    bool clearPet = false,
    RoomSeason? season,
  }) {
    return RoomModel(
      themeId: themeId ?? this.themeId,
      wallpaperItemId: clearWallpaper
          ? null
          : (wallpaperItemId ?? this.wallpaperItemId),
      floorItemId: clearFloor ? null : (floorItemId ?? this.floorItemId),
      furniture: furniture ?? this.furniture,
      petItemId: clearPet ? null : (petItemId ?? this.petItemId),
      season: season ?? this.season,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeId': themeId,
    'wallpaperItemId': wallpaperItemId,
    'floorItemId': floorItemId,
    'furniture': furniture.map((k, v) => MapEntry(k.name, v)),
    'petItemId': petItemId,
    'season': season.name,
  };

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final rawFurniture =
        (json['furniture'] as Map<String, dynamic>?) ?? const {};
    return RoomModel(
      themeId: json['themeId'] as String,
      wallpaperItemId: json['wallpaperItemId'] as String?,
      floorItemId: json['floorItemId'] as String?,
      furniture: rawFurniture.map(
        (k, v) => MapEntry(RoomSlot.values.byName(k), v as String),
      ),
      petItemId: json['petItemId'] as String?,
      season: RoomSeason.values.byName(json['season'] as String? ?? 'spring'),
    );
  }

  factory RoomModel.initial(String themeId) {
    return RoomModel(
      themeId: themeId,
      season: RoomSeason.fromDate(DateTime.now()),
    );
  }
}
