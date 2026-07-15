import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 key-value 저장소 추상화.
///
/// 모든 로컬 리포지토리는 이 인터페이스 위에서 JSON 문자열로 데이터를 저장한다.
/// 테스트에서는 [InMemoryLocalStore], 앱에서는 [SharedPreferencesLocalStore]를 쓴다.
abstract interface class LocalStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class InMemoryLocalStore implements LocalStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}

class SharedPreferencesLocalStore implements LocalStore {
  SharedPreferencesLocalStore(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const String _prefix = 'urizipak.';

  @override
  Future<String?> read(String key) => _prefs.getString('$_prefix$key');

  @override
  Future<void> write(String key, String value) =>
      _prefs.setString('$_prefix$key', value);

  @override
  Future<void> delete(String key) => _prefs.remove('$_prefix$key');
}
