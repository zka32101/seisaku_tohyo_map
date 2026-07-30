import 'package:flutter/material.dart';

import '../../infrastructure/local_storage/activity_store.dart';
import '../theme/app_theme.dart';

/// 初回起動時に表示する、コンテンツ利用規約への同意画面
///
/// コメント・提案などのユーザー投稿機能があるため、Apple/Googleのガイドライン
/// （不適切なコンテンツ・迷惑ユーザーを許容しないこと、通報・ブロック・削除手段があること）
/// を利用者に明示し、同意しないと先に進めないようにする。
class ContentPolicyScreen extends StatelessWidget {
  final VoidCallback onAccepted;

  const ContentPolicyScreen({super.key, required this.onAccepted});

  Future<void> _accept(BuildContext context) async {
    await ActivityStore().markContentPolicyAccepted();
    onAccepted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              const Icon(
                Icons.shield_outlined,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'ご利用の前に',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _PolicyItem(
                        icon: Icons.block,
                        title: '不適切なコンテンツ・迷惑行為は一切許容しません',
                        body:
                            '誹謗中傷、差別的な表現、個人情報の暴露、スパム、その他不適切な投稿は禁止です。'
                            '違反が確認された場合、投稿の削除およびアカウントの利用停止を行います。',
                      ),
                      SizedBox(height: AppSpacing.md),
                      _PolicyItem(
                        icon: Icons.flag_outlined,
                        title: '通報機能があります',
                        body:
                            '不適切な投稿を見つけた場合、各投稿のメニューから「報告する」で運営に通報できます。'
                            '通報内容は24時間以内に確認し、必要な対応を行います。',
                      ),
                      SizedBox(height: AppSpacing.md),
                      _PolicyItem(
                        icon: Icons.person_off_outlined,
                        title: 'ブロック機能があります',
                        body: '苦手なユーザーの投稿は、メニューから「このユーザーをブロック」で非表示にできます。',
                      ),
                      SizedBox(height: AppSpacing.md),
                      _PolicyItem(
                        icon: Icons.delete_outline,
                        title: '自分の投稿はいつでも削除できます',
                        body: '投稿したコメント・提案は、メニューから即座に削除できます。',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _accept(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('同意して始める'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PolicyItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
