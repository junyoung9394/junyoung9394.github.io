import 'package:flutter/foundation.dart';

import '../../domain/models/character.dart';
import '../../services/character_manager.dart';

/// 캐릭터 한 명(슬롯)의 표시 상태를 CharacterView에 공급하는 컨트롤러.
///
/// [Rive 준비 구조]
///   CharacterState → CharacterController → CharacterView → (현재) PNG
///                                                        → (추후) Rive
/// Rive 도입 시 이 컨트롤러가 상태 변화를 Rive state machine 입력으로
/// 변환하는 책임을 추가로 맡는다. CharacterView와 화면 코드는 변하지 않는다.
class CharacterController extends ChangeNotifier {
  CharacterController({required this._manager, required this.slot}) {
    _manager.addListener(_onManagerChanged);
    _profile = _manager.profileOf(slot);
  }

  final CharacterManager _manager;
  final PartnerSlot slot;

  late CharacterProfile _profile;

  CharacterProfile get profile => _profile;

  CharacterState get state => _profile.state;

  void _onManagerChanged() {
    final next = _manager.profileOf(slot);
    if (next == _profile) return;
    _profile = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _manager.removeListener(_onManagerChanged);
    super.dispose();
  }
}
