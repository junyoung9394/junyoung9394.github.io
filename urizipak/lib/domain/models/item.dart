/// 상점/인벤토리 아이템 모델.
library;

import 'character.dart' show PartnerSlot;
import 'room.dart' show RoomSlot;

enum ItemCategory {
  furniture('가구'),
  wallpaper('벽지'),
  floor('바닥'),
  background('배경'),
  outfit('의상'),
  accessory('액세서리'),
  pet('반려동물'),
  rare('희귀');

  const ItemCategory(this.label);

  final String label;
}

enum ItemRarity {
  common('일반'),
  rare('레어'),
  epic('에픽');

  const ItemRarity(this.label);

  final String label;
}

class ItemModel {
  const ItemModel({
    required this.id,
    required this.category,
    required this.name,
    required this.price,
    required this.emoji,
    this.rarity = ItemRarity.common,
    this.roomSlot,
    this.wearableBy,
    this.assetPath,
    this.description = '',
  });

  final String id;
  final ItemCategory category;
  final String name;

  /// AppMoney 가격.
  final int price;

  /// MVP 렌더링용 이모지. [assetPath]의 PNG가 준비되면 이미지가 우선.
  final String emoji;
  final ItemRarity rarity;

  /// 가구/반려동물이 배치될 수 있는 방 슬롯. 배치 불가 아이템은 null.
  final RoomSlot? roomSlot;

  /// 의상/액세서리를 착용할 수 있는 대상. null이면 남녀 공용.
  final PartnerSlot? wearableBy;

  /// PNG/Rive 에셋 경로 (준비 전에는 null → 이모지 렌더링).
  final String? assetPath;
  final String description;

  bool get isPlaceable => roomSlot != null;

  bool get isWearable =>
      category == ItemCategory.outfit || category == ItemCategory.accessory;

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'name': name,
    'price': price,
    'emoji': emoji,
    'rarity': rarity.name,
    'roomSlot': roomSlot?.name,
    'wearableBy': wearableBy?.name,
    'assetPath': assetPath,
    'description': description,
  };

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      category: ItemCategory.values.byName(json['category'] as String),
      name: json['name'] as String,
      price: json['price'] as int,
      emoji: json['emoji'] as String,
      rarity: ItemRarity.values.byName(json['rarity'] as String? ?? 'common'),
      roomSlot: json['roomSlot'] != null
          ? RoomSlot.values.byName(json['roomSlot'] as String)
          : null,
      wearableBy: json['wearableBy'] != null
          ? PartnerSlot.values.byName(json['wearableBy'] as String)
          : null,
      assetPath: json['assetPath'] as String?,
      description: json['description'] as String? ?? '',
    );
  }
}
