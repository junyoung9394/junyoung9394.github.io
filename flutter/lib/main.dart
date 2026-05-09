import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';
import 'widgets/app_open_ad_manager.dart';

const String kAdMobAppId = 'ca-app-pub-8518556382646891~6841226198';

final AppOpenAdManager appOpenAdManager = AppOpenAdManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  appOpenAdManager.loadAd();
  runApp(const RecycleApp());
}

class RecycleApp extends StatefulWidget {
  const RecycleApp({super.key});

  @override
  State<RecycleApp> createState() => _RecycleAppState();
}

class _RecycleAppState extends State<RecycleApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      appOpenAdManager.showAdIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '분리수거 끝판왕',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a7f4b),
        ),
        scaffoldBackgroundColor: const Color(0xFFf0faf4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a7f4b),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}
