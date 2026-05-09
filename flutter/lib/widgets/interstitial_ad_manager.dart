import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  static const String _adUnitId = 'ca-app-pub-8518556382646891/4568690186';
  static const int _showEvery = 3; // 3번째 아이템 열 때마다 전면 광고

  InterstitialAd? _ad;
  int _openCount = 0;

  InterstitialAdManager() {
    _load();
  }

  void _load() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _ad!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _ad = null;
              _load();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _ad = null;
              _load();
            },
          );
        },
        onAdFailedToLoad: (_) => _ad = null,
      ),
    );
  }

  /// 아이템 상세를 열 때마다 호출
  void onItemOpened() {
    _openCount++;
    if (_openCount % _showEvery == 0 && _ad != null) {
      _ad!.show();
    }
  }
}
