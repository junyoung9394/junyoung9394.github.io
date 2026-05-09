import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  static const String _adUnitId = 'ca-app-pub-8518556382646891/1577291227';
  static const Duration _adExpiry = Duration(hours: 4);

  AppOpenAd? _ad;
  bool _isShowingAd = false;
  DateTime? _loadTime;

  void loadAd() {
    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loadTime = DateTime.now();
        },
        onAdFailedToLoad: (_) => _ad = null,
      ),
    );
  }

  bool get _isAdValid {
    if (_ad == null || _loadTime == null) return false;
    return DateTime.now().difference(_loadTime!) < _adExpiry;
  }

  void showAdIfAvailable() {
    if (!_isAdValid || _isShowingAd) {
      if (!_isAdValid) loadAd();
      return;
    }
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowingAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _ad = null;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        _isShowingAd = false;
        ad.dispose();
        _ad = null;
        loadAd();
      },
    );
    _isShowingAd = true;
    _ad!.show();
  }
}
