import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/money.dart';
import '../../domain/models/character.dart';
import '../../theme/app_themes.dart';

/// 설정 화면: 테마, 캐릭터 선택, 코인 내역.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServicesScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          services.theme,
          services.characters,
          services.appMoney.listenable,
        ]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('앱 테마', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final themeId in AppThemeId.values)
                    ChoiceChip(
                      avatar: Text(themeId.emoji),
                      label: Text(themeId.koreanName),
                      selected: services.theme.current == themeId,
                      onSelected: (_) => services.theme.setTheme(themeId),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('우리 캐릭터', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final slot in PartnerSlot.values)
                _CharacterPicker(slot: slot),
              const SizedBox(height: 24),
              Text('코인 내역', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Text('🪙', style: TextStyle(fontSize: 24)),
                      title: const Text('현재 잔액'),
                      trailing: Text(
                        formatComma(services.appMoney.balance),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (services.appMoney.history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('아직 내역이 없어요'),
                      ),
                    for (final entry in services.appMoney.history.take(20))
                      ListTile(
                        dense: true,
                        title: Text(entry.reason),
                        subtitle: Text(
                          '${entry.createdAt.month}/${entry.createdAt.day} · ${entry.type.label}',
                        ),
                        trailing: Text(
                          entry.amount >= 0
                              ? '+${formatComma(entry.amount)}'
                              : formatComma(entry.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: entry.amount >= 0
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.favorite_outline),
                  title: Text('우리지갑'),
                  subtitle: Text(
                    '함께 쓰고, 함께 모으고, 함께 키우는\n커플 공동 자산관리 플랫폼 · v0.1.0',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CharacterPicker extends StatelessWidget {
  const _CharacterPicker({required this.slot});

  final PartnerSlot slot;

  @override
  Widget build(BuildContext context) {
    final characters = AppServicesScope.of(context).characters;
    final profile = characters.profileOf(slot);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${slot.label} 캐릭터',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final species in CharacterSpecies.values)
                  ChoiceChip(
                    avatar: Text(species.emoji),
                    label: Text(species.label),
                    selected: profile.species == species,
                    onSelected: (_) => characters.selectSpecies(slot, species),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
