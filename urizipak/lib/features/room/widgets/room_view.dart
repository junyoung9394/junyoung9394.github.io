import 'package:flutter/material.dart';

import '../../../domain/models/room.dart';
import '../../../theme/app_themes.dart';
import '../../character/character_controller.dart';
import '../../character/character_view.dart';
import '../room_view_model.dart';

/// 방의 시각적 표현. Slot 방식 고정 배치.
///
/// 벽/바닥은 현재 테마 색으로 칠하고, 각 슬롯은 고정 좌표에 놓인다.
/// 추후 벽지/바닥 아이템 에셋이 생기면 색 대신 이미지를 깐다.
class RoomView extends StatelessWidget {
  const RoomView({
    super.key,
    required this.viewModel,
    required this.maleController,
    required this.femaleController,
    required this.onSlotTap,
  });

  final RoomViewModel viewModel;
  final CharacterController maleController;
  final CharacterController femaleController;
  final void Function(RoomSlot slot) onSlotTap;

  // 슬롯별 고정 위치 (0.0~1.0 비율 좌표: left, top).
  static const Map<RoomSlot, Offset> _slotPositions = {
    RoomSlot.wall: Offset(0.40, 0.06),
    RoomSlot.plant: Offset(0.06, 0.30),
    RoomSlot.bed: Offset(0.72, 0.30),
    RoomSlot.sofa: Offset(0.08, 0.56),
    RoomSlot.table: Offset(0.42, 0.62),
    RoomSlot.rug: Offset(0.40, 0.82),
    RoomSlot.pet: Offset(0.78, 0.78),
  };

  @override
  Widget build(BuildContext context) {
    final themeId = AppThemeId.fromName(viewModel.room.themeId);
    return AspectRatio(
      aspectRatio: 1.05,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return Stack(
              children: [
                // 벽
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          themeId.roomBackgroundColor,
                          themeId.roomBackgroundColor.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // 바닥
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: h * 0.34,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: themeId.seedColor.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                // 슬롯들
                for (final entry in _slotPositions.entries)
                  Positioned(
                    left: entry.value.dx * w,
                    top: entry.value.dy * h,
                    child: _SlotWidget(
                      slot: entry.key,
                      viewModel: viewModel,
                      size: w * 0.17,
                      onTap: () => onSlotTap(entry.key),
                    ),
                  ),
                // 우리 둘 — 방의 주인공
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: h * 0.05,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CharacterView(controller: maleController, size: w * 0.22),
                      SizedBox(width: w * 0.05),
                      CharacterView(
                        controller: femaleController,
                        size: w * 0.22,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlotWidget extends StatelessWidget {
  const _SlotWidget({
    required this.slot,
    required this.viewModel,
    required this.size,
    required this.onTap,
  });

  final RoomSlot slot;
  final RoomViewModel viewModel;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = viewModel.placedItem(slot);
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: item?.name ?? '${slot.label} 놓기',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: item != null
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(size / 4),
                  border: Border.all(color: scheme.outlineVariant, width: 1.2),
                  color: scheme.surface.withValues(alpha: 0.35),
                ),
          child: item != null
              ? Text(item.emoji, style: TextStyle(fontSize: size * 0.62))
              : Opacity(
                  opacity: 0.45,
                  child: Text(
                    slot.placeholderEmoji,
                    style: TextStyle(fontSize: size * 0.42),
                  ),
                ),
        ),
      ),
    );
  }
}
