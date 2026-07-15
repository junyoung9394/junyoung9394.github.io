import 'package:flutter_test/flutter_test.dart';
import 'package:urizipak/app/di.dart';
import 'package:urizipak/data/local/local_couple_connector.dart';
import 'package:urizipak/data/local/local_store.dart';
import 'package:urizipak/domain/models/character.dart';
import 'package:urizipak/domain/models/couple.dart';

void main() {
  late InMemoryLocalStore store;
  late AppServices services;

  setUp(() async {
    store = InMemoryLocalStore();
    services = await AppServices.create(storeOverride: store);
  });

  tearDown(() => services.dispose());

  test('초기 상태는 solo', () {
    expect(services.couple.status, CoupleStatus.solo);
    expect(services.couple.isConnected, isFalse);
  });

  test('초대 코드 발급 → waiting 상태 + 6자리 코드', () async {
    final code = await services.couple.issueInviteCode();
    expect(code.length, LocalCoupleConnector.codeLength);
    expect(services.couple.status, CoupleStatus.waiting);
    expect(services.couple.link.inviteCode, code);
  });

  test('상대방 코드로 연결 → connected + 캐릭터 love 반응', () async {
    await services.couple.connectWithCode('abc123');
    await pumpEventQueue();

    expect(services.couple.isConnected, isTrue);
    expect(services.couple.link.coupleId, isNotNull);
    // CoupleConnected 이벤트 → CharacterManager가 love로 반응
    expect(
      services.characters.profileOf(PartnerSlot.male).state,
      CharacterState.love,
    );
  });

  test('잘못된 형식의 코드는 거부된다', () async {
    expect(
      () => services.couple.connectWithCode('!!'),
      throwsA(isA<InvalidInviteCodeException>()),
    );
    expect(services.couple.status, CoupleStatus.solo);
  });

  test('연결 상태는 앱 재시작 후에도 유지된다', () async {
    await services.couple.connectWithCode('QWE789');
    services.dispose();

    // 같은 저장소로 서비스 재생성 = 앱 재시작
    services = await AppServices.create(storeOverride: store);
    expect(services.couple.isConnected, isTrue);
  });

  test('연결 해제 → solo로 복귀', () async {
    await services.couple.connectWithCode('QWE789');
    await services.couple.disconnect();
    expect(services.couple.status, CoupleStatus.solo);
  });
}
