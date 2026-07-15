import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/event_bus.dart';
import '../../core/money.dart';
import '../assets/assets_screen.dart';
import '../goals/goals_screen.dart';
import '../ledger/ledger_screen.dart';
import '../room/room_screen.dart';
import '../shop/shop_screen.dart';

/// 하단 내비게이션 셸.
///
/// 첫 탭은 숫자가 아니라 "우리 공간"이다 — 앱을 열면 집과 캐릭터가 먼저 보인다.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  StreamSubscription<RewardGranted>? _rewardSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 보상 지급 순간을 토스트로 축하한다 (어느 탭에 있든).
    _rewardSubscription ??= AppServicesScope.of(
      context,
    ).bus.on<RewardGranted>().listen(_showRewardToast);
  }

  @override
  void dispose() {
    _rewardSubscription?.cancel();
    super.dispose();
  }

  void _showRewardToast(RewardGranted event) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Text('${event.label}  +${formatComma(event.amount)} 코인'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          RoomScreen(),
          LedgerScreen(),
          GoalsScreen(),
          AssetsScreen(),
          ShopScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '우리 공간',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: '가계부',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: '목표',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: '자산',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: '상점',
          ),
        ],
      ),
    );
  }
}
