import 'package:flutter_test/flutter_test.dart';
import 'package:urizipak/app/di.dart';
import 'package:urizipak/app/urizipak_app.dart';
import 'package:urizipak/data/local/local_store.dart';
import 'package:urizipak/services/character_manager.dart';

void main() {
  testWidgets('앱을 열면 우리 공간이 가장 먼저 보인다', (tester) async {
    final services = await AppServices.create(
      storeOverride: InMemoryLocalStore(),
    );

    await tester.pumpWidget(UrizipakApp(services: services));
    await tester.pump();

    expect(find.text('우리 공간'), findsWidgets);
    // 하단 내비게이션 5탭
    expect(find.text('가계부'), findsOneWidget);
    expect(find.text('목표'), findsOneWidget);
    expect(find.text('자산'), findsOneWidget);
    expect(find.text('상점'), findsOneWidget);

    // 출석 보상 → 캐릭터 celebrate 반응 타이머 소진
    await tester.pump(CharacterManager.reactionDuration);
    await tester.pump(const Duration(seconds: 1));

    services.dispose();
  });
}
