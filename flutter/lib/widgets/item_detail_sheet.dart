import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/item.dart';
import 'ad_banner_widget.dart';

class ItemDetailSheet extends StatelessWidget {
  final RecycleItem item;
  const ItemDetailSheet({super.key, required this.item});

  static void show(BuildContext context, RecycleItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ItemDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                // 이모지 + 이름
                Text(item.emoji, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                Text(item.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Center(child: _CategoryChip(item.category)),
                const SizedBox(height: 20),

                // 버리는 곳
                _SectionHeader('버리는 곳'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe8f5ed),
                    borderRadius: BorderRadius.circular(14),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF1a7f4b), width: 4),
                    ),
                  ),
                  child: Text(item.where,
                      style: const TextStyle(
                          color: Color(0xFF1a7f4b),
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
                const SizedBox(height: 16),

                // 버리는 방법
                _SectionHeader('버리는 방법'),
                ...item.steps.asMap().entries.map((e) => _StepTile(
                    number: e.key + 1, text: e.value)),
                const SizedBox(height: 16),

                // 팁
                if (item.tips.isNotEmpty) ...[
                  _SectionHeader('꼭 알아두기'),
                  ...item.tips.map((t) => _TipTile(t)),
                  const SizedBox(height: 16),
                ],

                // 예외
                if (item.exception != null) ...[
                  _ExceptionBox(item.exception!),
                  const SizedBox(height: 16),
                ],

                // 광고
                const Center(child: AdBannerWidget()),
                const SizedBox(height: 12),

                // 공유 버튼
                FilledButton.tonal(
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(
                      text: '♻️ ${item.name} → ${item.where}\n'
                          '${item.steps.join(' → ')}\n\n'
                          'https://junyoung9394.github.io/recycle/',
                      subject: '분리수거: ${item.name}',
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('🔗 공유하기', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
                letterSpacing: 1)),
      );
}

class _StepTile extends StatelessWidget {
  final int number;
  final String text;
  const _StepTile({required this.number, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(
                  color: Color(0xFF1a7f4b), shape: BoxShape.circle),
              child: Center(
                child: Text('$number',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 15, height: 1.5)),
            ),
          ],
        ),
      );
}

class _TipTile extends StatelessWidget {
  final String text;
  const _TipTile(this.text);
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('💡 $text',
            style: const TextStyle(fontSize: 13.5, height: 1.5)),
      );
}

class _ExceptionBox extends StatelessWidget {
  final String text;
  const _ExceptionBox(this.text);
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(12),
          border: const Border(
              left: BorderSide(color: Color(0xFFFCA5A5), width: 3)),
        ),
        child: Text('⚠️ $text',
            style: const TextStyle(
                color: Color(0xFF9F1239), fontSize: 13.5, height: 1.5)),
      );
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip(this.category);

  Color get bg => switch (category) {
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

  Color get fg => switch (category) {
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(category,
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
      );
}
