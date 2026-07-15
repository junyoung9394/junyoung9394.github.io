import 'package:flutter/material.dart';

import '../core/event_bus.dart';
import '../domain/repositories/repositories.dart';
import '../theme/app_themes.dart';

/// 앱 테마 서비스.
///
/// 테마 변경 시 [ThemeChanged] 이벤트를 발행한다.
/// 캐릭터/방 등 다른 모듈은 이 서비스를 모르고 이벤트만 구독한다.
class ThemeService extends ChangeNotifier {
  ThemeService({required this._settings, required this._bus});

  final SettingsRepository _settings;
  final AppEventBus _bus;

  static const String _key = 'theme.id';

  AppThemeId _current = AppThemeId.peach;

  Future<void> init() async {
    _current = AppThemeId.fromName(await _settings.getString(_key));
    notifyListeners();
  }

  AppThemeId get current => _current;

  ThemeData get themeData => buildThemeData(_current);

  Future<void> setTheme(AppThemeId id) async {
    if (_current == id) return;
    _current = id;
    await _settings.setString(_key, id.name);
    notifyListeners();
    _bus.publish(ThemeChanged(themeId: id.name));
  }
}
