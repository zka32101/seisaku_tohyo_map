import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/pension_provider.dart';
import '../../application/usecases/calculate_pension_loss.dart';
import '../../application/usecases/check_new_achievements.dart';
import '../../domain/entities/pension_calculation.dart';
import '../../infrastructure/analytics/analytics_service.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../../utils/widget_image_capture.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_unlock_dialog.dart';
import '../widgets/loss_share_card.dart';
import 'share_preview_screen.dart';

class AgeInputScreen extends ConsumerStatefulWidget {
  const AgeInputScreen({super.key});

  @override
  ConsumerState<AgeInputScreen> createState() => _AgeInputScreenState();
}

class _AgeInputScreenState extends ConsumerState<AgeInputScreen> {
  late TextEditingController _ageController;
  int? _selectedAge;
  final _shareCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitAge() async {
    FocusScope.of(context).unfocus();
    final age = int.tryParse(_ageController.text);
    if (age == null || age < 20 || age > 80) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('20〜80の数字で入力してください')));
      return;
    }

    setState(() => _selectedAge = age);
    ref.read(userAgeProvider.notifier).state = age;

    final pension = CalculatePensionLoss.call(age);
    AnalyticsService().logLossCalculated(age: age, lossAmount: pension.netLoss);

    final newlyUnlocked = await CheckNewAchievements.call(
      () => ActivityStore().markPensionCalculated(),
    );
    if (newlyUnlocked.isNotEmpty && mounted) {
      showAchievementUnlockDialogs(context, newlyUnlocked);
    }
  }

  void _reset() {
    setState(() => _selectedAge = null);
    _ageController.clear();
  }

  Future<void> _shareCard(PensionCalculation pension) async {
    final bytes = await captureRepaintBoundaryImage(_shareCardKey);
    if (bytes == null || !mounted) return;

    final signedAmount =
        '${pension.isInTheMinus ? '△' : '+'}¥${(pension.netLoss.abs() / 10000).toStringAsFixed(0)}万円';
    final text =
        '日本の未来マップ 診断結果\n'
        '${pension.age}歳の生涯年金損益: $signedAmount\n'
        'あなたの結果もチェックしてみよう！';

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SharePreviewScreen(imageBytes: bytes, shareText: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('日本の未来マップ')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_selectedAge == null ? 'question' : 'result'),
                  child: _selectedAge == null
                      ? _buildQuestion()
                      : _buildResult(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _selectedAge != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('日本の未来を見る'),
                ),
              ),
            )
          : null,
    );
  }

  // 質問一つだけを画面いっぱいに見せる、シンプルな入力ステップ
  Widget _buildQuestion() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'あなたの年金は\n得？損？',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          '年齢を入力するだけで、\n生涯の年金の損得がわかります',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: AppSpacing.xxl),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          autofocus: true,
          onSubmitted: (_) => _submitAge(),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
          decoration: const InputDecoration(
            hintText: '30',
            suffixText: '歳',
            suffixStyle: TextStyle(fontSize: 20, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitAge,
            child: const Text('結果を見る'),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final pensionAsync = ref.watch(selectedPensionProvider);

    return pensionAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 80),
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Text('エラー: $err'),
      data: (pension) {
        if (pension == null) return const SizedBox.shrink();

        final isLoss = pension.isInTheMinus;
        final tone = isLoss ? AppColors.danger : AppColors.success;
        final toneLight = isLoss
            ? AppColors.dangerLight
            : AppColors.successLight;

        return Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              '${pension.age}歳のあなたの結果',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isLoss ? '生涯で損をします' : '生涯で得をします',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: tone,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // メインの数字カード
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xl,
                horizontal: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: toneLight,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  Text(
                    isLoss ? '△' : '+',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: tone,
                    ),
                  ),
                  Text(
                    '¥${(pension.netLoss.abs() / 10000).toStringAsFixed(0)}万円',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: tone,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '納めた額の${pension.lossRate.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 内訳（納める・受け取る）をシンプルな2列で
            Row(
              children: [
                Expanded(
                  child: _BreakdownTile(
                    label: '納める',
                    amount: pension.totalContributions,
                    icon: Icons.arrow_upward,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _BreakdownTile(
                    label: '受け取る',
                    amount: pension.totalBenefits,
                    icon: Icons.arrow_downward,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 画像キャプチャ用（非表示）。RepaintBoundary で画像化する。
            // OverflowBox は zero-size な位置にそのまま描画してしまい他要素と重なるため、
            // Transform.translate で画面外へ実際に移動させてから overflow させる。
            SizedBox(
              height: 0,
              width: 0,
              child: Transform.translate(
                offset: const Offset(-9999, -9999),
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: 0,
                  minHeight: 0,
                  maxWidth: 360,
                  maxHeight: 900,
                  child: RepaintBoundary(
                    key: _shareCardKey,
                    child: LossShareCard(pension: pension),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _shareCard(pension),
                icon: const Icon(Icons.image, size: 18),
                label: const Text('結果を画像でシェア'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(onPressed: _reset, child: const Text('別の年齢で試す')),
          ],
        );
      },
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _BreakdownTile({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '¥${(amount / 10000).toStringAsFixed(0)}万',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
