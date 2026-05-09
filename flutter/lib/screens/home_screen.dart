import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/items.dart';
import '../models/item.dart';
import '../widgets/item_detail_sheet.dart';
import '../widgets/ad_banner_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCat = '전체';
  List<String> _recentSearches = [];
  List<RecycleItem> _results = kItems;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveRecent(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = [query, ..._recentSearches.where((r) => r != query)]
        .take(8)
        .toList();
    await prefs.setStringList('recent_searches', _recentSearches);
    setState(() {});
  }

  Future<void> _clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() => _recentSearches = []);
  }

  void _onQueryChange(String query) {
    setState(() {
      _query = query.trim();
      _searching = _query.isNotEmpty;
      _results = _query.isEmpty
          ? _filterByCat(kItems)
          : (kItems
              .map((i) => (item: i, s: i.score(_query)))
              .where((e) => e.s > 0)
              .toList()
            ..sort((a, b) => b.s.compareTo(a.s)))
              .map((e) => e.item)
              .toList();
    });
  }

  void _selectQuery(String query) {
    _searchCtrl.text = query;
    _onQueryChange(query);
    _saveRecent(query);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _onQueryChange('');
  }

  List<RecycleItem> _filterByCat(List<RecycleItem> items) =>
      _selectedCat == '전체' ? items : items.where((i) => i.category == _selectedCat).toList();

  void _selectCategory(String cat) {
    setState(() {
      _selectedCat = cat;
      _searching = false;
      _query = '';
      _searchCtrl.clear();
      _results = _filterByCat(kItems);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar + 검색창 ──────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: SearchBar(
                  controller: _searchCtrl,
                  hintText: '예: 치킨박스, 아이스팩, 빨대…',
                  leading: const Icon(Icons.search, size: 20),
                  trailing: [
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: _clearSearch,
                      ),
                  ],
                  onChanged: _onQueryChange,
                  onSubmitted: (q) {
                    if (q.trim().isNotEmpty) _saveRecent(q.trim());
                  },
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  elevation: WidgetStateProperty.all(1),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
            title: const Text('♻️ 분리수거 가이드',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(),
            ),
          ),

          // ── 상단 광고 ────────────────────────────────────────
          const SliverToBoxAdapter(
            child: ColoredBox(
              color: Colors.white,
              child: Center(child: AdBannerWidget()),
            ),
          ),

          // ── 자주 찾는 품목 ────────────────────────────────────
          if (!_searching)
            SliverToBoxAdapter(
              child: _ChipSection(
                title: '자주 찾는 품목',
                chips: kPopular,
                onTap: _selectQuery,
              ),
            ),

          // ── 최근 검색어 ───────────────────────────────────────
          if (!_searching && _recentSearches.isNotEmpty)
            SliverToBoxAdapter(
              child: _ChipSection(
                title: '최근 검색어',
                chips: _recentSearches,
                onTap: _selectQuery,
                trailing: TextButton(
                  onPressed: _clearRecent,
                  child: const Text('전체 삭제',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                isRecent: true,
              ),
            ),

          // ── 카테고리 탭 ───────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _CatTabDelegate(
              selectedCat: _selectedCat,
              onSelect: _selectCategory,
            ),
          ),

          // ── 결과 카운트 ───────────────────────────────────────
          if (_searching && _results.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text('검색 결과 ${_results.length}개',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ),
            ),

          // ── 빈 결과 ───────────────────────────────────────────
          if (_results.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('😅', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('검색 결과가 없어요',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Text('다른 키워드로 찾아보거나\n카테고리를 눌러보세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),

          // ── 아이템 그리드 ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ItemCard(
                  item: _results[i],
                  onTap: () {
                    if (_query.isNotEmpty) _saveRecent(_query);
                    ItemDetailSheet.show(ctx, _results[i]);
                  },
                ),
                childCount: _results.length,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
            ),
          ),

          // ── 하단 광고 + 여백 ──────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Center(child: AdBannerWidget()),
            ),
          ),
        ],
      ),
    );
  }
}

/* ─── 카테고리 탭 헤더 ─────────────────────────────────────── */
class _CatTabDelegate extends SliverPersistentHeaderDelegate {
  final String selectedCat;
  final void Function(String) onSelect;
  const _CatTabDelegate({required this.selectedCat, required this.onSelect});

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlaps) =>
      Container(
        color: Colors.white,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: kCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final cat = kCategories[i];
            final active = cat == selectedCat;
            return ChoiceChip(
              label: Text(cat),
              selected: active,
              onSelected: (_) => onSelect(cat),
              selectedColor: const Color(0xFF1a7f4b),
              labelStyle: TextStyle(
                color: active ? Colors.white : const Color(0xFF5a7a62),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFd1e9da)),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            );
          },
        ),
      );

  @override
  bool shouldRebuild(_CatTabDelegate old) =>
      old.selectedCat != selectedCat;
}

/* ─── 빠른 선택 칩 섹션 ─────────────────────────────────────── */
class _ChipSection extends StatelessWidget {
  final String title;
  final List<String> chips;
  final void Function(String) onTap;
  final Widget? trailing;
  final bool isRecent;

  const _ChipSection({
    required this.title,
    required this.chips,
    required this.onTap,
    this.trailing,
    this.isRecent = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                        letterSpacing: 0.8)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: chips.map((c) => ActionChip(
                    label: Text(isRecent ? '🕐 $c' : c),
                    onPressed: () => onTap(c),
                    backgroundColor: isRecent ? const Color(0xFFF8F8F8) : const Color(0xFFe8f5ed),
                    labelStyle: TextStyle(
                        fontSize: 12.5,
                        color: isRecent ? Colors.black87 : const Color(0xFF1a7f4b),
                        fontWeight: FontWeight.w600),
                    side: BorderSide(
                        color: isRecent ? const Color(0xFFE5E7EB) : const Color(0xFFd1e9da)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  )).toList(),
            ),
          ],
        ),
      );
}

/* ─── 아이템 카드 ────────────────────────────────────────────── */
class _ItemCard extends StatelessWidget {
  final RecycleItem item;
  final VoidCallback onTap;
  const _ItemCard({required this.item, required this.onTap});

  Color get _badgeBg => switch (item.category) {
    '종이류'    => const Color(0xFFFEF3C7),
    '플라스틱류'  => const Color(0xFFDBEAFE),
    '유리류'    => const Color(0xFFD1FAE5),
    '금속류'    => const Color(0xFFE5E7EB),
    '비닐류'    => const Color(0xFFEDE9FE),
    '스티로폼'   => const Color(0xFFFFF1F2),
    '음식물'    => const Color(0xFFECFCCB),
    '일반쓰레기'  => const Color(0xFFF3F4F6),
    '특수수거'   => const Color(0xFFFCE7F3),
    _          => const Color(0xFFE5E7EB),
  };

  Color get _badgeFg => switch (item.category) {
    '종이류'    => const Color(0xFF92400E),
    '플라스틱류'  => const Color(0xFF1E40AF),
    '유리류'    => const Color(0xFF065F46),
    '금속류'    => const Color(0xFF374151),
    '비닐류'    => const Color(0xFF4C1D95),
    '스티로폼'   => const Color(0xFF881337),
    '음식물'    => const Color(0xFF365314),
    '일반쓰레기'  => const Color(0xFF6B7280),
    '특수수거'   => const Color(0xFF831843),
    _          => const Color(0xFF374151),
  };

  @override
  Widget build(BuildContext context) => Card(
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFd1e9da)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 8),
                Text(item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _badgeBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(item.category,
                      style: TextStyle(
                          color: _badgeFg,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 4),
                Text(
                  item.where.split('(').first.trim(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      );
}
