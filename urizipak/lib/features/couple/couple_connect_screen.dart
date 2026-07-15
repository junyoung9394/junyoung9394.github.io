import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/di.dart';
import '../../data/local/local_couple_connector.dart';
import '../../domain/models/couple.dart';

/// 커플 연결 화면.
///
/// [광고 정책] 이 흐름(커플 연결)에는 어떤 광고도 노출하지 않는다.
/// 서로의 초대 코드 중 하나로 연결한다:
/// 내 코드를 발급해 상대에게 알려주거나, 상대의 코드를 입력한다.
class CoupleConnectScreen extends StatefulWidget {
  const CoupleConnectScreen({super.key});

  @override
  State<CoupleConnectScreen> createState() => _CoupleConnectScreenState();
}

class _CoupleConnectScreenState extends State<CoupleConnectScreen> {
  final _codeController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _issueCode() async {
    setState(() => _busy = true);
    await AppServicesScope.of(context).couple.issueInviteCode();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _connect() async {
    final couple = AppServicesScope.of(context).couple;
    setState(() => _busy = true);
    try {
      await couple.connectWithCode(_codeController.text);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('연결 완료! 이제 둘이 함께예요 💕')));
      }
    } on InvalidInviteCodeException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('코드 형식이 올바르지 않아요 (영문 대문자·숫자 6자리)')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final couple = AppServicesScope.of(context).couple;
    return Scaffold(
      appBar: AppBar(title: const Text('커플 연결')),
      body: ListenableBuilder(
        listenable: couple,
        builder: (context, _) {
          final link = couple.link;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusCard(link: link),
              const SizedBox(height: 16),
              if (link.status == CoupleStatus.connected)
                OutlinedButton.icon(
                  icon: const Icon(Icons.link_off),
                  label: const Text('연결 해제'),
                  onPressed: _busy ? null : () => couple.disconnect(),
                )
              else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '내 초대 코드',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        if (link.inviteCode != null)
                          Row(
                            children: [
                              Text(
                                link.inviteCode!,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 4,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                tooltip: '복사',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: link.inviteCode!),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('코드를 복사했어요')),
                                  );
                                },
                              ),
                            ],
                          )
                        else
                          const Text('코드를 발급해서 상대방에게 알려주세요.'),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: _busy ? null : _issueCode,
                          child: Text(
                            link.inviteCode == null ? '코드 발급하기' : '새 코드 발급',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '상대방 코드 입력',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: LocalCoupleConnector.codeLength,
                          decoration: const InputDecoration(
                            labelText: '초대 코드 6자리',
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _busy ? null : _connect,
                            child: const Text('연결하기'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '지금은 기기 안에서만 연결 상태가 저장돼요.\n'
                  '클라우드 동기화(Firebase)가 연결되면 상대방과 실시간으로\n'
                  '가계부·목표·우리 공간이 함께 움직입니다.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.link});

  final CoupleLink link;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (emoji, description) = switch (link.status) {
      CoupleStatus.solo => ('🙂', '아직 혼자 쓰고 있어요'),
      CoupleStatus.waiting => ('⏳', '상대방이 코드를 입력하면 연결돼요'),
      CoupleStatus.connected => ('💕', '둘이 함께 쓰는 중이에요'),
    };
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(
          link.status.label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
        ),
      ),
    );
  }
}
