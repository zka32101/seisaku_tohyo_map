import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../local_storage/activity_store.dart';

/// 広告の表示要否とバナー広告ユニットIDを管理する。
///
/// 広告ユニットIDは、下記Googleの公開TEST用ID
/// （https://developers.google.com/admob/android/test-ads ,
/// https://developers.google.com/admob/ios/test-ads）をプレースホルダーとして
/// 使用している。ストア配信前に、AdMobコンソールで取得した実際のユニットIDに
/// 置き換える必要がある（AndroidManifest.xml / Info.plistのアプリIDも同様）。
class AdService {
  AdService._();

  static const String _testBannerAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerAdUnitIdIOS =
      'ca-app-pub-3940256099942544/2934735716';

  static String get bannerAdUnitId =>
      Platform.isIOS ? _testBannerAdUnitIdIOS : _testBannerAdUnitIdAndroid;

  static bool _initialized = false;

  /// SDK初期化前に広告を読み込もうとすると失敗するため、main()から
  /// 必ず呼び出すこと。単体テスト（main()を経由しない）では呼ばれないため、
  /// [isInitialized]はfalseのままとなり、広告ウィジェットは何も読み込まない。
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  static bool get isInitialized => _initialized;

  /// 一度でも寄付（金額を問わず）していれば、以降は広告を一切表示しない。
  static bool get shouldShowAds => ActivityStore().donationCount == 0;
}
