import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/event_bus.dart';
import '../domain/models/character.dart';
import '../domain/repositories/repositories.dart';

/// 커플 캐릭터 총괄 매니저.
///
/// 역할: 남자/여자 캐릭터 선택, 현재 상태, 현재 의상, 현재 테마, 현재 집 관리.
///
/// 다른 모듈을 직접 알지 못한다. 이벤트 버스를 구독해서
/// 거래 기록 → happy, 저축 → love, 보상/목표 달성 → celebrate 로 반응하고
/// 잠시 후 기본 상태로 돌아온다. (Rive 도입 시 이 상태 전환이 그대로
/// 애니메이션 트리거가 된다.)
class CharacterManager extends ChangeNotifier {
  CharacterManager({
    required this._repository,
    required this._settings,
    required this._bus,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CharacterRepository _repository;
  final SettingsRepository _settings;
  final AppEventBus _bus;
  final DateTime Function() _clock;

  static const String _houseKey = 'character.houseId';
  static const String _themeKey = 'character.themeId';
  static const Duration reactionDuration = Duration(seconds: 4);

  Map<PartnerSlot, CharacterProfile> _profiles = {};
  String _currentHouseId = 'house_basic';
  String _currentThemeId = 'peach';
  Timer? _reactionTimer;
  final List<StreamSubscription<AppEvent>> _subscriptions = [];

  Future<void> init() async {
    final saved = await _repository.loadProfiles();
    _profiles = {
      for (final slot in PartnerSlot.values)
        slot: saved[slot] ?? CharacterProfile.defaultFor(slot),
    };
    _currentHouseId = await _settings.getString(_houseKey) ?? 'house_basic';
    _currentThemeId = await _settings.getString(_themeKey) ?? 'peach';
    _resetToBaseState();

    _subscriptions
      ..add(
        _bus.on<TransactionRecorded>().listen(
          (_) => reactBoth(CharacterState.happy),
        ),
      )
      ..add(
        _bus.on<GoalContributionAdded>().listen(
          (_) => reactBoth(CharacterState.love),
        ),
      )
      ..add(
        _bus.on<RewardGranted>().listen(
          (_) => reactBoth(CharacterState.celebrate),
        ),
      )
      ..add(_bus.on<ThemeChanged>().listen((e) => _applyTheme(e.themeId)));
    notifyListeners();
  }

  @override
  void dispose() {
    _reactionTimer?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  CharacterProfile profileOf(PartnerSlot slot) => _profiles[slot]!;

  List<CharacterProfile> get profiles =>
      PartnerSlot.values.map((s) => _profiles[s]!).toList();

  String get currentHouseId => _currentHouseId;

  String get currentThemeId => _currentThemeId;

  /// 캐릭터 종 선택. 남자/여자 각자 따로 선택할 수 있다.
  Future<void> selectSpecies(PartnerSlot slot, CharacterSpecies species) async {
    _profiles[slot] = _profiles[slot]!.copyWith(species: species);
    await _persist();
    notifyListeners();
  }

  /// 의상 착용. 소유 검증은 호출자(ViewModel이 InventoryService로) 책임.
  Future<void> equipOutfit(PartnerSlot slot, String? itemId) async {
    _profiles[slot] = _profiles[slot]!.copyWith(
      outfitItemId: itemId,
      clearOutfit: itemId == null,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> equipAccessory(PartnerSlot slot, String? itemId) async {
    _profiles[slot] = _profiles[slot]!.copyWith(
      accessoryItemId: itemId,
      clearAccessory: itemId == null,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> selectHouse(String houseId) async {
    _currentHouseId = houseId;
    await _settings.setString(_houseKey, houseId);
    notifyListeners();
  }

  /// 두 캐릭터가 잠시 반응했다가 기본 상태로 돌아온다.
  void reactBoth(CharacterState state) {
    _reactionTimer?.cancel();
    for (final slot in PartnerSlot.values) {
      _profiles[slot] = _profiles[slot]!.copyWith(state: state);
    }
    notifyListeners();
    _reactionTimer = Timer(reactionDuration, () {
      _resetToBaseState();
      notifyListeners();
    });
  }

  /// 시간대 기반 기본 상태. 밤(22시~7시)에는 졸린 모습.
  CharacterState get baseState {
    final hour = _clock().hour;
    return (hour >= 22 || hour < 7)
        ? CharacterState.sleepy
        : CharacterState.idle;
  }

  void _resetToBaseState() {
    final base = baseState;
    for (final slot in PartnerSlot.values) {
      _profiles[slot] = _profiles[slot]!.copyWith(state: base);
    }
  }

  Future<void> _applyTheme(String themeId) async {
    _currentThemeId = themeId;
    await _settings.setString(_themeKey, themeId);
    // 향후: 테마 전용 의상/스킨 자동 적용 지점.
    notifyListeners();
  }

  Future<void> _persist() => _repository.saveProfiles(_profiles);
}
