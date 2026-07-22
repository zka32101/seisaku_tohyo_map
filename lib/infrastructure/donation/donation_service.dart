import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/donation_tier.dart';

/// アプリ内課金（消費型アイテム）による寄付機能
///
/// `in_app_purchase`パッケージはAndroid（Google Play課金）・iOS（App Store/StoreKit）の
/// 両方に対応するfederated pluginのため、このクラスのコードはプラットフォーム分岐なしで動く。
/// 商品ID（donation_small/medium/large）は、Google Play Console／App Store Connectの
/// 双方で事前に「消費型（Consumable）」アプリ内アイテムとして登録しておく必要がある。
/// 未登録の間は`queryProductDetails`が空を返すため、寄付ボタンは「準備中」表示になる。
class DonationService {
  static final DonationService _instance = DonationService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final Logger _logger = Logger();
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  DonationService._internal();

  factory DonationService() => _instance;

  static final Set<String> _productIds = DonationTier.all
      .map((t) => t.productId)
      .toSet();

  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } catch (e) {
      _logger.e('Error checking IAP availability: $e');
      return false;
    }
  }

  Future<Map<String, ProductDetails>> queryProducts() async {
    try {
      final response = await _iap.queryProductDetails(_productIds);
      if (response.error != null) {
        _logger.e('Error querying products: ${response.error}');
      }
      return {for (final p in response.productDetails) p.id: p};
    } catch (e) {
      _logger.e('Error querying products: $e');
      return {};
    }
  }

  void listenToPurchases({
    required void Function(PurchaseDetails purchase) onSuccess,
    required void Function(PurchaseDetails purchase) onError,
  }) {
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          onSuccess(purchase);
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
        } else if (purchase.status == PurchaseStatus.error) {
          _logger.e('Purchase error: ${purchase.error}');
          onError(purchase);
        }
      }
    }, onError: (e) => _logger.e('Purchase stream error: $e'));
  }

  Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    // 寄付は繰り返し購入できる消費型アイテムとして扱う
    await _iap.buyConsumable(purchaseParam: param);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
