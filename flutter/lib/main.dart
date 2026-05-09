import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';

// ★ AdMob 앱 ID — https://admob.google.com 에서 생성 후 교체
const String kAdMobAppId = 'ca-app-pub-8518556382646891~REPLACE_APP_ID';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const RecycleApp());
}

class RecycleApp extends StatelessWidget {
  const RecycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '분리수거 가이드',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a7f4b),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFf0faf4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a7f4b),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFe8f5ed),
          labelStyle: const TextStyle(color: Color(0xFF1a7f4b), fontWeight: FontWeight.w600),
          side: const BorderSide(color: Color(0xFFd1e9da)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}
