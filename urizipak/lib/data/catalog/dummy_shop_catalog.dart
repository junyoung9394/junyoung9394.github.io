/// MVP용 더미 상점 카탈로그.
///
/// 추후 Firebase(Firestore/Remote Config) 카탈로그 구현으로 교체한다.
library;

import '../../domain/models/character.dart';
import '../../domain/models/item.dart';
import '../../domain/models/room.dart';
import '../../domain/repositories/repositories.dart';

class DummyShopCatalogRepository implements ShopCatalogRepository {
  const DummyShopCatalogRepository();

  @override
  Future<List<ItemModel>> loadCatalog() async => dummyItems;

  static const List<ItemModel> dummyItems = [
    // ── 가구 ──────────────────────────────────────────────
    ItemModel(
      id: 'furniture_bed_basic',
      category: ItemCategory.furniture,
      name: '포근한 침대',
      price: 300,
      emoji: '🛏️',
      roomSlot: RoomSlot.bed,
      description: '둘이 눕기엔 조금 좁지만 그래서 더 좋은 침대.',
    ),
    ItemModel(
      id: 'furniture_sofa_rattan',
      category: ItemCategory.furniture,
      name: '라탄 소파',
      price: 400,
      emoji: '🛋️',
      roomSlot: RoomSlot.sofa,
      description: '주말 아침 커피 한 잔이 어울리는 소파.',
    ),
    ItemModel(
      id: 'furniture_table_wood',
      category: ItemCategory.furniture,
      name: '원목 테이블',
      price: 350,
      emoji: '🪑',
      roomSlot: RoomSlot.table,
      description: '가계부 회의(?)가 열리는 우리 집 본부.',
    ),
    ItemModel(
      id: 'furniture_plant_monstera',
      category: ItemCategory.furniture,
      name: '몬스테라 화분',
      price: 150,
      emoji: '🪴',
      roomSlot: RoomSlot.plant,
      description: '돈나무는 아니지만 마음이 자라요.',
    ),
    ItemModel(
      id: 'furniture_wall_frame',
      category: ItemCategory.furniture,
      name: '우리 사진 액자',
      price: 200,
      emoji: '🖼️',
      roomSlot: RoomSlot.wall,
      description: '첫 여행 사진을 걸어둘 곳.',
    ),
    ItemModel(
      id: 'furniture_rug_cloud',
      category: ItemCategory.furniture,
      name: '구름 러그',
      price: 250,
      emoji: '☁️',
      roomSlot: RoomSlot.rug,
      description: '밟을 때마다 폭신한 기분.',
    ),
    // ── 벽지 / 바닥 / 배경 ────────────────────────────────
    ItemModel(
      id: 'wallpaper_peach_stripe',
      category: ItemCategory.wallpaper,
      name: '피치 스트라이프 벽지',
      price: 300,
      emoji: '🍑',
      description: '은은한 복숭아빛 줄무늬 벽지.',
    ),
    ItemModel(
      id: 'floor_maple_wood',
      category: ItemCategory.floor,
      name: '메이플 원목 바닥',
      price: 300,
      emoji: '🪵',
      description: '맨발로 걷고 싶은 원목 바닥.',
    ),
    ItemModel(
      id: 'background_night_city',
      category: ItemCategory.background,
      name: '야경 창문 뷰',
      price: 500,
      emoji: '🌃',
      description: '창밖으로 보이는 반짝이는 도시.',
    ),
    // ── 의상 / 액세서리 ──────────────────────────────────
    ItemModel(
      id: 'outfit_hoodie_couple',
      category: ItemCategory.outfit,
      name: '커플 후드티',
      price: 400,
      emoji: '🧥',
      description: '남녀 공용. 같이 입으면 두 배로 귀엽습니다.',
    ),
    ItemModel(
      id: 'outfit_dress_daisy',
      category: ItemCategory.outfit,
      name: '데이지 원피스',
      price: 350,
      emoji: '👗',
      wearableBy: PartnerSlot.female,
      description: '봄 소풍에 딱 어울리는 원피스.',
    ),
    ItemModel(
      id: 'accessory_cap_blue',
      category: ItemCategory.accessory,
      name: '파란 볼캡',
      price: 150,
      emoji: '🧢',
      wearableBy: PartnerSlot.male,
      description: '어디에나 어울리는 데일리 캡.',
    ),
    ItemModel(
      id: 'accessory_ribbon_pink',
      category: ItemCategory.accessory,
      name: '핑크 리본',
      price: 150,
      emoji: '🎀',
      wearableBy: PartnerSlot.female,
      description: '포인트가 필요할 때.',
    ),
    // ── 반려동물 ─────────────────────────────────────────
    ItemModel(
      id: 'pet_goldfish',
      category: ItemCategory.pet,
      name: '금붕어 어항',
      price: 300,
      emoji: '🐠',
      roomSlot: RoomSlot.pet,
      description: '뻐끔뻐끔. 보고만 있어도 힐링.',
    ),
    ItemModel(
      id: 'pet_hamster',
      category: ItemCategory.pet,
      name: '햄스터',
      price: 450,
      emoji: '🐹',
      roomSlot: RoomSlot.pet,
      description: '볼주머니에 저축하는 우리 집 재테크 선배.',
    ),
    // ── 희귀 아이템 ──────────────────────────────────────
    ItemModel(
      id: 'rare_fireplace',
      category: ItemCategory.rare,
      name: '벽난로',
      price: 2000,
      emoji: '🔥',
      rarity: ItemRarity.epic,
      roomSlot: RoomSlot.wall,
      description: '겨울밤을 완성하는 최고급 벽난로.',
    ),
    ItemModel(
      id: 'rare_star_projector',
      category: ItemCategory.rare,
      name: '별빛 프로젝터',
      price: 1500,
      emoji: '🌌',
      rarity: ItemRarity.rare,
      roomSlot: RoomSlot.table,
      description: '천장 가득 쏟아지는 은하수.',
    ),
  ];
}
