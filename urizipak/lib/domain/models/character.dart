/// 캐릭터 도메인 모델.
///
/// 현재는 상태값만 관리하고 애니메이션은 없다.
/// 추후 Rive 도입 시 [CharacterState]가 Rive state machine 입력으로 매핑된다.
library;

/// 캐릭터의 감정/행동 상태.
///
/// PNG 시대: 상태별 정지 이미지 1장 (`<species>_<state>.png`)
/// Rive 시대: 상태별 애니메이션 트리거
enum CharacterState {
  idle('기본'),
  sleepy('졸림'),
  happy('기쁨'),
  celebrate('축하'),
  wave('인사'),
  love('사랑');

  const CharacterState(this.label);

  final String label;
}

/// 선택 가능한 캐릭터 종.
enum CharacterSpecies {
  otter('수달', '🦦'),
  beaver('비버', '🦫'),
  bear('곰', '🐻'),
  rabbit('토끼', '🐰'),
  dog('강아지', '🐶'),
  cat('고양이', '🐱');

  const CharacterSpecies(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// 커플 구성원 슬롯. 남자/여자 캐릭터를 각자 따로 선택한다.
enum PartnerSlot {
  male('남자'),
  female('여자');

  const PartnerSlot(this.label);

  final String label;
}

/// 구성원 한 명의 캐릭터 프로필.
class CharacterProfile {
  const CharacterProfile({
    required this.slot,
    required this.species,
    this.state = CharacterState.idle,
    this.outfitItemId,
    this.accessoryItemId,
  });

  final PartnerSlot slot;
  final CharacterSpecies species;
  final CharacterState state;

  /// 착용 중인 의상 아이템 ID (Inventory 소유 아이템).
  final String? outfitItemId;

  /// 착용 중인 액세서리 아이템 ID.
  final String? accessoryItemId;

  /// PNG 렌더러가 사용할 에셋 경로.
  /// 파일이 없으면 CharacterView가 이모지 플레이스홀더로 대체한다.
  String get assetPath => 'assets/characters/${species.name}_${state.name}.png';

  CharacterProfile copyWith({
    CharacterSpecies? species,
    CharacterState? state,
    String? outfitItemId,
    bool clearOutfit = false,
    String? accessoryItemId,
    bool clearAccessory = false,
  }) {
    return CharacterProfile(
      slot: slot,
      species: species ?? this.species,
      state: state ?? this.state,
      outfitItemId: clearOutfit ? null : (outfitItemId ?? this.outfitItemId),
      accessoryItemId: clearAccessory
          ? null
          : (accessoryItemId ?? this.accessoryItemId),
    );
  }

  Map<String, dynamic> toJson() => {
    'slot': slot.name,
    'species': species.name,
    'state': state.name,
    'outfitItemId': outfitItemId,
    'accessoryItemId': accessoryItemId,
  };

  factory CharacterProfile.fromJson(Map<String, dynamic> json) {
    return CharacterProfile(
      slot: PartnerSlot.values.byName(json['slot'] as String),
      species: CharacterSpecies.values.byName(json['species'] as String),
      state: CharacterState.values.byName(json['state'] as String? ?? 'idle'),
      outfitItemId: json['outfitItemId'] as String?,
      accessoryItemId: json['accessoryItemId'] as String?,
    );
  }

  factory CharacterProfile.defaultFor(PartnerSlot slot) {
    return CharacterProfile(
      slot: slot,
      species: slot == PartnerSlot.male
          ? CharacterSpecies.bear
          : CharacterSpecies.otter,
    );
  }
}
