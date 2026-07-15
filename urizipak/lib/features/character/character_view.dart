import 'package:flutter/material.dart';

import 'character_controller.dart';
import 'character_renderer.dart';

/// 앱 전체에서 캐릭터를 그리는 유일한 위젯.
///
/// [규칙] 캐릭터를 화면에 그릴 때는 반드시 CharacterView만 사용한다.
/// Image.asset()을 화면 코드에서 직접 쓰지 않는다.
/// 렌더링 방식(PNG → Rive)이 바뀌어도 이 위젯을 쓰는 화면은 수정되지 않는다.
class CharacterView extends StatelessWidget {
  const CharacterView({
    super.key,
    required this.controller,
    this.size = 96,
    this.renderer = const PngCharacterRenderer(),
    this.showLabel = false,
  });

  final CharacterController controller;
  final double size;

  /// 렌더링 전략. Rive 도입 시 RiveCharacterRenderer로 교체.
  final CharacterRenderer renderer;

  /// 캐릭터 아래에 이름(종) 라벨 표시 여부.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final profile = controller.profile;
        final character = AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(
            key: ValueKey('${profile.species.name}_${profile.state.name}'),
            child: renderer.build(context, profile, size),
          ),
        );
        if (!showLabel) return character;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            character,
            const SizedBox(height: 4),
            Text(
              '${profile.slot.label} · ${profile.species.label}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      },
    );
  }
}
