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
              Image.asset(
                'assets/images/content_policy_header.png',
                height: 96,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'ご利用の前に / Before you continue',
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
                        titleEn: 'Zero tolerance for objectionable content',
                        bodyEn:
                            'We do not tolerate abusive, harassing, hateful, or otherwise '
                            'objectionable content, or abusive users. Violating posts will be '
                            'removed and offending users will be ejected from the service.',
                      ),
                      SizedBox(height: AppSpacing.md),
                      _PolicyItem(
                        icon: Icons.flag_outlined,
                        title: '通報機能があります',
                        body:
                            '不適切な投稿を見つけた場合、各投稿のメニューから「報告する」で運営に通報できます。'
                            '通報内容は24時間以内に確認し、必要な対応を行います。',
                        titleEn: 'Flag objectionable content',
                        bodyEn:
                            'Tap the ⋮ menu on any comment or proposal and choose "Report" '
                            'to flag it to us. We review reports and act within 24 hours.',
                      ),
                      SizedBox(height: AppSpacing.md),
                      _PolicyItem(
                        icon: Icons.person_off_outlined,
                        title: 'ブロック機能があります',
                        body: '苦手なユーザーの投稿は、メニューから「このユーザーをブロック」で非表示にできます。',
                        titleEn: 'Block abusive users',
                        bodyEn:
                            'Tap the ⋮ menu and choose "Block this user" to hide their posts '
                            'on this device.',
                      ),
                      SizedBox(height: AppSpacing.md),
                      _PolicyItem(
                        icon: Icons.delete_outline,
                        title: '自分の投稿はいつでも削除できます',
                        body: '投稿したコメント・提案は、メニューから即座に削除できます。',
                        titleEn: 'Remove your own posts instantly',
                        bodyEn:
                            'Tap the ⋮ menu on your own comment or proposal and choose '
                            '"Delete" to remove it from the feed immediately.',
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
                  child: const Text('同意して始める / Agree & Continue'),
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
  final String titleEn;
  final String bodyEn;

  const _PolicyItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.titleEn,
    required this.bodyEn,
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
              const SizedBox(height: 6),
              Text(
                titleEn,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                bodyEn,
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
