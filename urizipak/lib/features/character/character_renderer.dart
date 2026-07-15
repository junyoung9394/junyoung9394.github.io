import 'package:flutter/material.dart';

import '../../domain/models/character.dart';

/// 캐릭터를 실제로 그리는 전략 인터페이스.
///
/// 현재 구현: [PngCharacterRenderer]
/// 추후 구현: RiveCharacterRenderer — rive 패키지 추가 후 이 인터페이스만
/// 구현해서 CharacterView의 renderer를 교체하면 된다. UI 코드 수정 없음.
abstract interface class CharacterRenderer {
  Widget build(BuildContext context, CharacterProfile profile, double size);
}

/// PNG 정지 이미지 렌더러.
///
/// `assets/characters/<species>_<state>.png`를 그린다.
/// 에셋이 아직 없으면 이모지 플레이스홀더로 대체한다 —
/// 디자인 에셋이 도착하는 즉시 코드 수정 없이 이미지가 나타난다.
class PngCharacterRenderer implements CharacterRenderer {
  const PngCharacterRenderer();

  @override
  Widget build(BuildContext context, CharacterProfile profile, double size) {
    return Image.asset(
      profile.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          _EmojiPlaceholder(profile: profile, size: size),
    );
  }
}

class _EmojiPlaceholder extends StatelessWidget {
  const _EmojiPlaceholder({required this.profile, required this.size});

  final CharacterProfile profile;
  final double size;

  static const Map<CharacterState, String> _stateBadges = {
    CharacterState.sleepy: '💤',
    CharacterState.happy: '✨',
    CharacterState.celebrate: '🎉',
    CharacterState.wave: '👋',
    CharacterState.love: '💕',
  };

  @override
  Widget build(BuildContext context) {
    final badge = _stateBadges[profile.state];
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(profile.species.emoji, style: TextStyle(fontSize: size * 0.62)),
          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Text(badge, style: TextStyle(fontSize: size * 0.28)),
            ),
        ],
      ),
    );
  }
}
