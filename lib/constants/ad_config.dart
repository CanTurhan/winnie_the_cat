import 'dart:io';

class AdConfig {
  static const bool useTestAds = true;

  static const String iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const String iosTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  static const String androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // TODO: Replace before release.
  static const String iosProductionBannerAdUnitId =
      'ca-app-pub-8274979068153688/REPLACE_WITH_WINNIE_BANNER_ID';

  static String get bannerAdUnitId {
    if (useTestAds) {
      if (Platform.isIOS) return iosTestBannerAdUnitId;
      if (Platform.isAndroid) return androidTestBannerAdUnitId;
    }

    if (Platform.isIOS) return iosProductionBannerAdUnitId;

    throw UnsupportedError('Unsupported platform for ads');
  }
}
