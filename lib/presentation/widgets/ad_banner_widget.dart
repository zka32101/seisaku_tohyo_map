import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

import '../../infrastructure/ads/ad_service.dart';

final _logger = Logger();

/// 標準バナー広告。一度でも寄付したユーザーには表示しない
/// （[AdService.shouldShowAds]を参照）。広告の読み込みに失敗した場合も
/// 何も表示しない（レイアウト崩れを避けるため）。
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (AdService.isInitialized && AdService.shouldShowAds) {
      _loadAd();
    }
  }

  // 実機のAdMob SDK（プラットフォームチャンネル）が無い環境（単体テスト等）でも
  // 落ちないよう、ActivityStoreなど他のインフラ系クラスと同様に例外を握りつぶす。
  void _loadAd() {
    try {
      final ad = BannerAd(
        adUnitId: AdService.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (!mounted) return;
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      );
      _bannerAd = ad;
      ad.load().catchError((e) {
        _logger.e('Error loading banner ad: $e');
      });
    } catch (e) {
      _logger.e('Error creating banner ad: $e');
    }
  }

  @override
  void dispose() {
    try {
      _bannerAd?.dispose();
    } catch (e) {
      _logger.e('Error disposing banner ad: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.shouldShowAds || !_loaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
