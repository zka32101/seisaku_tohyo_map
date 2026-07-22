import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../application/usecases/check_new_achievements.dart';
import '../../domain/entities/donation_tier.dart';
import '../../infrastructure/analytics/analytics_service.dart';
import '../../infrastructure/donation/donation_service.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_unlock_dialog.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _service = DonationService();
  Map<String, ProductDetails> _products = {};
  bool _loading = true;
  bool _available = false;
  String? _purchasingProductId;

  @override
  void initState() {
    super.initState();
    _service.listenToPurchases(
      onSuccess: _onPurchaseSuccess,
      onError: _onPurchaseError,
    );
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final available = await _service.isAvailable();
    final products = available
        ? await _service.queryProducts()
        : <String, ProductDetails>{};
    if (!mounted) return;
    setState(() {
      _available = available;
      _products = products;
      _loading = false;
    });
  }

  Future<void> _onPurchaseSuccess(PurchaseDetails purchase) async {
    if (!mounted) return;
    setState(() => _purchasingProductId = null);
    AnalyticsService().logDonationPurchased(productId: purchase.productID);
    final newlyUnlocked = await CheckNewAchievements.call(
      () => ActivityStore().incrementDonationCount(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ご支援ありがとうございます！🎉')));
    if (newlyUnlocked.isNotEmpty) {
      showAchievementUnlockDialogs(context, newlyUnlocked);
    }
  }

  void _onPurchaseError(PurchaseDetails purchase) {
    if (!mounted) return;
    setState(() => _purchasingProductId = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('決済に失敗しました')));
  }

  Future<void> _buy(DonationTier tier) async {
    final product = _products[tier.productId];
    if (product == null || _purchasingProductId != null) return;

    setState(() => _purchasingProductId = tier.productId);
    try {
      await _service.buy(product);
    } catch (_) {
      if (!mounted) return;
      setState(() => _purchasingProductId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('決済を開始できませんでした')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('応援する')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.block_flipped,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'このアプリに広告はありません',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      '広告収益に頼らず、みなさまからの寄付で開発・運営を続けています。'
                      '社会課題に向き合うこのアプリを気に入っていただけたら、'
                      '応援いただけると励みになります。',
                      style: TextStyle(fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (!_available || _products.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    '寄付機能は現在準備中です。もうしばらくお待ちください。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                )
              else
                ...DonationTier.all
                    .where((tier) => _products.containsKey(tier.productId))
                    .map(
                      (tier) => _DonationTierCard(
                        tier: tier,
                        product: _products[tier.productId]!,
                        purchasing: _purchasingProductId == tier.productId,
                        disabled:
                            _purchasingProductId != null &&
                            _purchasingProductId != tier.productId,
                        onTap: () => _buy(tier),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonationTierCard extends StatelessWidget {
  final DonationTier tier;
  final ProductDetails product;
  final bool purchasing;
  final bool disabled;
  final VoidCallback onTap;

  const _DonationTierCard({
    required this.tier,
    required this.product,
    required this.purchasing,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(tier.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tier.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: disabled ? null : onTap,
            child: purchasing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(product.price),
          ),
        ],
      ),
    );
  }
}
