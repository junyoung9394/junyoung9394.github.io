class RecycleItem {
  final String name;
  final List<String> aliases;
  final String category;
  final String emoji;
  final String where;
  final List<String> steps;
  final List<String> tips;
  final String? exception;

  const RecycleItem({
    required this.name,
    required this.aliases,
    required this.category,
    required this.emoji,
    required this.where,
    required this.steps,
    this.tips = const [],
    this.exception,
  });

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.replaceAll(' ', '').toLowerCase();
    if (name.replaceAll(' ', '').toLowerCase().contains(q)) return true;
    return aliases.any((a) => a.replaceAll(' ', '').toLowerCase().contains(q));
  }

  int score(String query) {
    if (query.isEmpty) return 0;
    final q = query.replaceAll(' ', '').toLowerCase();
    final n = name.replaceAll(' ', '').toLowerCase();
    if (n == q) return 100;
    if (n.startsWith(q)) return 80;
    if (n.contains(q)) return 60;
    final aliasNorm = aliases.map((a) => a.replaceAll(' ', '').toLowerCase()).toList();
    if (aliasNorm.contains(q)) return 75;
    if (aliasNorm.any((a) => a.startsWith(q))) return 55;
    if (aliasNorm.any((a) => a.contains(q))) return 40;
    return 0;
  }
}
