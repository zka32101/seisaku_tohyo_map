import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

// pubspec.yaml の version と手動で同期させる（package_info_plus 等の追加依存を避けるため）
const _appVersion = '1.0.0';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('このアプリについて')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            '日本の未来マップ',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'v$_appVersion',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionCard(
            title: 'このアプリについて',
            icon: Icons.info_outline,
            body:
                '「日本の未来って、実際どうなってるの？」\n\n'
                '漠然とした不安を、具体的な数字と一次資料で理解できるアプリです。'
                '年金・国債・少子高齢化から、選挙制度や官僚機構といった政治の構造的な課題まで、'
                '50件以上のトピックを公式統計・一次資料に基づいて分かりやすく解説します。',
          ),
          const SizedBox(height: AppSpacing.md),

          const _SectionCard(
            title: '主な機能',
            icon: Icons.checklist_outlined,
            body:
                '・年齢を入れるだけの年金損益診断\n'
                '・課題への投票／賛同、対策案の選択\n'
                '・投票数だけでなく、注目度や関連する国の予算規模でマッピングする「マップ」表示\n'
                '・国会での実際の議案、政党・個人が公に示している主張との連動\n'
                '・運営者が関係省庁・窓口へ問い合わせた記録の公開\n'
                '・ギャップクイズ、世界との比較、みんなの声・提案',
          ),
          const SizedBox(height: AppSpacing.md),

          const _SectionCard(
            title: 'データについて',
            icon: Icons.fact_check_outlined,
            body:
                '掲載している数値・議案・主張は、政府統計や一次資料、報道等に基づくスナップショットです。'
                '制度改正や国会審議の進捗により内容が変わることがあるため、各課題の「情報時点」表示と'
                '出典リンクをあわせてご確認ください。',
          ),
          const SizedBox(height: AppSpacing.md),

          const _SectionCard(
            title: '不適切な投稿について',
            icon: Icons.flag_outlined,
            body:
                '誹謗中傷・差別的表現・個人情報の暴露・スパム等の不適切な投稿は禁止しています。'
                '各コメント・提案のメニューから「報告する」ことで運営に通報でき、'
                '通報内容は24時間以内に確認のうえ、削除等の対応を行います。'
                '苦手なユーザーは「ブロック」から非表示にでき、自分の投稿はいつでも削除できます。'
                '緊急の通報や、アプリ内で対応できない場合は下記の連絡先まで直接ご連絡ください。',
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text(
            'リンク',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LinkRow(
            icon: Icons.privacy_tip_outlined,
            label: 'プライバシーポリシー',
            url:
                'https://zka32103-coder.github.io/petitworks-legal/nihon_future_map/privacy.html',
          ),
          _LinkRow(
            icon: Icons.support_agent_outlined,
            label: 'サポート・お問い合わせ',
            url:
                'https://zka32103-coder.github.io/petitworks-legal/nihon_future_map/support.html',
          ),
          _LinkRow(
            icon: Icons.mail_outline,
            label: '運営に直接メールで連絡する（不適切な投稿の通報含む）',
            url:
                'mailto:petitworksdev@gmail.com?subject=${Uri.encodeComponent('【日本の未来マップ】お問い合わせ')}',
          ),
          const SizedBox(height: AppSpacing.lg),

          const Center(
            child: Text(
              '運営: Petit Works Apps',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String body;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.7)),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _LinkRow({required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.badge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.badge),
        onTap: () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 13)),
              ),
              const Icon(
                Icons.open_in_new,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
