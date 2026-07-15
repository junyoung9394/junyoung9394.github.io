import 'package:flutter/material.dart';

/// 우리지갑 앱 테마.
///
/// 현재는 Flutter [ThemeData]만 바꾼다.
/// 향후 같은 [AppThemeId]로 집/버튼/캐릭터 의상/가구/배경 스킨을 함께 바꾼다.
/// (테마 변경 시 ThemeChanged 이벤트가 발행되어 CharacterManager/RoomService가
/// 이미 구독하고 있다 — 스킨 에셋만 준비되면 연결 지점은 완성돼 있다.)
enum AppThemeId {
  peach('Peach', '복숭아', '🍑', Color(0xFFFF8A65), Color(0xFFFFF3E0)),
  cherryBlossom(
    'Cherry Blossom',
    '벚꽃',
    '🌸',
    Color(0xFFF06292),
    Color(0xFFFCE4EC),
  ),
  mint('Mint', '민트', '🌿', Color(0xFF26A69A), Color(0xFFE0F2F1)),
  sky('Sky', '하늘', '☁️', Color(0xFF42A5F5), Color(0xFFE3F2FD)),
  lavender('Lavender', '라벤더', '💜', Color(0xFF9575CD), Color(0xFFEDE7F6)),
  lemon('Lemon', '레몬', '🍋', Color(0xFFF9A825), Color(0xFFFFFDE7)),
  cocoa('Cocoa', '코코아', '🍫', Color(0xFF8D6E63), Color(0xFFEFEBE9));

  const AppThemeId(
    this.displayName,
    this.koreanName,
    this.emoji,
    this.seedColor,
    this.roomBackgroundColor,
  );

  final String displayName;
  final String koreanName;
  final String emoji;

  /// ColorScheme 시드 컬러.
  final Color seedColor;

  /// 우리 공간(방) 배경에 쓰이는 은은한 톤.
  final Color roomBackgroundColor;

  static AppThemeId fromName(String? name) {
    if (name == null) return AppThemeId.peach;
    return AppThemeId.values.asNameMap()[name] ?? AppThemeId.peach;
  }
}

/// [AppThemeId] → [ThemeData] 빌더.
ThemeData buildThemeData(AppThemeId id) {
  final scheme = ColorScheme.fromSeed(seedColor: id.seedColor);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
    ),
  );
}
