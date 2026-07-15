import 'package:flutter_test/flutter_test.dart';
import 'package:urizipak/app/di.dart';
import 'package:urizipak/data/catalog/dummy_shop_catalog.dart';
import 'package:urizipak/data/local/local_store.dart';
import 'package:urizipak/domain/models/reward.dart';
import 'package:urizipak/domain/models/room.dart';
import 'package:urizipak/domain/models/transaction_entry.dart';
import 'package:urizipak/services/app_money_ledger.dart';

/// 우리지갑의 핵심 순환 검증:
/// 기록/목표/저축 → RewardService 보상 → AppMoney → 상점 구매 → 우리 공간 배치
void main() {
  late AppServices services;

  setUp(() async {
    services = await AppServices.create(storeOverride: InMemoryLocalStore());
  });

  tearDown(() => services.dispose());

  test('앱 첫 실행 시 출석 보상이 지급된다', () {
    expect(services.appMoney.balance, RewardEvent.dailyCheckIn.amount);
  });

  test('첫 거래 기록 → 첫 거래 보상 지급', () async {
    await services.transactions.add(
      type: TransactionType.expense,
      amount: 12000,
      category: TransactionCategory.food,
      date: DateTime.now(),
      recordedBy: RecordedBy.partnerA,
    );
    await pumpEventQueue();

    expect(
      services.appMoney.balance,
      RewardEvent.dailyCheckIn.amount + RewardEvent.firstTransaction.amount,
    );
    // 두 번째 거래는 첫 거래 보상이 다시 지급되지 않는다.
    await services.transactions.add(
      type: TransactionType.expense,
      amount: 5000,
      category: TransactionCategory.cafe,
      date: DateTime.now(),
      recordedBy: RecordedBy.partnerB,
    );
    await pumpEventQueue();
    expect(
      services.appMoney.balance,
      RewardEvent.dailyCheckIn.amount + RewardEvent.firstTransaction.amount,
    );
  });

  test('목표 생성 → 저축 → 달성까지 보상이 순서대로 지급된다', () async {
    final goal = await services.goals.create(
      title: '제주 여행',
      emoji: '✈️',
      targetAmount: 100000,
    );
    await pumpEventQueue();

    var expected =
        RewardEvent.dailyCheckIn.amount + RewardEvent.firstGoal.amount;
    expect(services.appMoney.balance, expected);

    await services.goals.contribute(
      goalId: goal.id,
      amount: 40000,
      contributedBy: RecordedBy.partnerA,
    );
    await pumpEventQueue();
    expected += RewardEvent.savingSuccess.amount;
    expect(services.appMoney.balance, expected);

    final achieved = await services.goals.contribute(
      goalId: goal.id,
      amount: 60000,
      contributedBy: RecordedBy.partnerB,
    );
    await pumpEventQueue();
    expected +=
        RewardEvent.savingSuccess.amount + RewardEvent.goalAchieved.amount;
    expect(achieved.isAchieved, isTrue);
    expect(services.appMoney.balance, expected);
  });

  test('보상 코인으로 아이템 구매 → 우리 공간 배치', () async {
    final goal = await services.goals.create(
      title: '신혼집 보증금',
      emoji: '🏠',
      targetAmount: 1000,
    );
    await services.goals.contribute(
      goalId: goal.id,
      amount: 1000,
      contributedBy: RecordedBy.partnerA,
    );
    await pumpEventQueue();

    final plant = services.shop.itemById('furniture_plant_monstera')!;
    expect(services.appMoney.canAfford(plant.price), isTrue);

    await services.inventory.purchase(plant);
    expect(services.inventory.owns(plant.id), isTrue);

    await services.room.placeItem(RoomSlot.plant, plant.id);
    expect(services.room.room.itemAt(RoomSlot.plant), plant.id);
  });

  test('잔액 부족 시 구매가 거부된다 (직접 적립 불가 원칙)', () async {
    final fireplace = DummyShopCatalogRepository.dummyItems.firstWhere(
      (i) => i.id == 'rare_fireplace',
    );
    expect(
      () => services.inventory.purchase(fireplace),
      throwsA(isA<InsufficientAppMoneyException>()),
    );
  });
}
