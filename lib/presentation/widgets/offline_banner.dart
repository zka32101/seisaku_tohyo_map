import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/connectivity_provider.dart';
import '../theme/app_theme.dart';

/// オフライン時にのみ表示する注意バナー
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: AppColors.danger),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'オフラインです。直近のデータを表示しています。投票・コメントはネットワーク復帰後に反映されます。',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.danger,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
