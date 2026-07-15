import 'dart:convert';

import 'local_store.dart';

/// [LocalStore] 위에 JSON 배열로 저장되는 컬렉션 헬퍼.
///
/// 로컬 리포지토리 구현들이 공통으로 사용하는 직렬화/역직렬화 로직을 모아
/// 각 리포지토리 파일을 얇게 유지한다.
class JsonCollection<T> {
  JsonCollection({
    required this.store,
    required this.storageKey,
    required this.toJson,
    required this.fromJson,
    required this.idOf,
  });

  final LocalStore store;
  final String storageKey;
  final Map<String, dynamic> Function(T item) toJson;
  final T Function(Map<String, dynamic> json) fromJson;
  final String Function(T item) idOf;

  Future<List<T>> loadAll() async {
    final raw = await store.read(storageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList(growable: true);
  }

  Future<void> saveAll(List<T> items) async {
    final encoded = jsonEncode(items.map(toJson).toList());
    await store.write(storageKey, encoded);
  }

  /// 같은 ID가 있으면 교체, 없으면 추가(upsert).
  Future<void> upsert(T item) async {
    final items = await loadAll();
    final index = items.indexWhere((e) => idOf(e) == idOf(item));
    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }
    await saveAll(items);
  }

  Future<void> deleteById(String id) async {
    final items = await loadAll();
    items.removeWhere((e) => idOf(e) == id);
    await saveAll(items);
  }
}
