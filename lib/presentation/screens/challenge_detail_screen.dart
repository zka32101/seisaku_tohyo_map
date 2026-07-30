import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/providers/agency_contact_provider.dart';
import '../../application/providers/challenge_detail_provider.dart';
import '../../application/providers/connectivity_provider.dart';
import '../../application/providers/diet_bill_provider.dart';
import '../../application/providers/firebase_provider.dart';
import '../../application/providers/international_comparison_provider.dart';
import '../../application/providers/issue_advocate_provider.dart';
import '../../application/usecases/check_new_achievements.dart';
import '../../application/usecases/load_agency_contacts.dart';
import '../../application/usecases/load_diet_bills.dart';
import '../../application/usecases/load_issue_advocates.dart';
import '../../application/usecases/validate_comment.dart';
import '../../domain/entities/agency_contact.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/challenge_data.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/diet_bill.dart';
import '../../domain/entities/issue_advocate.dart';
import '../../domain/entities/policy_option.dart';
import '../../infrastructure/analytics/analytics_service.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_unlock_dialog.dart';
import '../widgets/chart_axis.dart';
import '../widgets/glossary_text.dart';
import '../widgets/international_comparison_section.dart';
import '../widgets/offline_banner.dart';
import '../widgets/ugc_action_menu.dart';
import 'glossary_screen.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final Challenge challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  final _scrollController = ScrollController();
  final _dataKey = GlobalKey();
  final _outlookKey = GlobalKey();
  final _agreementKey = GlobalKey();
  final _dietBillKey = GlobalKey();
  final _advocateKey = GlobalKey();
  final _agencyContactKey = GlobalKey();
  final _intlKey = GlobalKey();
  final _policyKey = GlobalKey();
  final _commentsKey = GlobalKey();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 400;
    if (shouldShow != _showBackToTop) {
      setState(() => _showBackToTop = shouldShow);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _jumpTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final detailAsync = ref.watch(challengeDetailProvider(challenge.id));
    final color = AppColors.categoryColor(challenge.category);
    final intlComparison = ref.watch(
      internationalComparisonProvider(challenge.id),
    );
    final hasDietBills = LoadDietBills.forChallenge(challenge.id).isNotEmpty;
    final hasAdvocates = LoadIssueAdvocates.forChallenge(
      challenge.id,
    ).isNotEmpty;
    final hasAgencyContacts = LoadAgencyContacts.forChallenge(
      challenge.id,
    ).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: '用語集',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const GlossaryScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _SectionJumpBar(
            color: color,
            onDataTap: () => _jumpTo(_dataKey),
            onOutlookTap: () => _jumpTo(_outlookKey),
            onAgreementTap: () => _jumpTo(_agreementKey),
            onDietBillTap: hasDietBills ? () => _jumpTo(_dietBillKey) : null,
            onAdvocateTap: hasAdvocates ? () => _jumpTo(_advocateKey) : null,
            onAgencyContactTap: hasAgencyContacts
                ? () => _jumpTo(_agencyContactKey)
                : null,
            onIntlTap: intlComparison != null ? () => _jumpTo(_intlKey) : null,
            onPolicyTap: () => _jumpTo(_policyKey),
            onCommentsTap: () => _jumpTo(_commentsKey),
          ),
        ),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              tooltip: 'トップに戻る',
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (detail) {
          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const OfflineBanner(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppColors.categoryIcon(challenge.category),
                      size: 12,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppColors.categoryLabel(challenge.category),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlossaryText(
                challenge.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              if (detail.detailedDescription != null) ...[
                const SizedBox(height: AppSpacing.md),
                GlossaryText(
                  detail.detailedDescription!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.7,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              // マクロ→ミクロのつながり
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        const Text(
                          'あなたの生活とのつながり',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GlossaryText(
                      detail.macroConnection,
                      style: const TextStyle(fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (detail.dataSeries.isNotEmpty) ...[
                Text(
                  key: _dataKey,
                  '公式データ vs 民間分析',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ComparisonChart(dataSeries: detail.dataSeries, color: color),
                const SizedBox(height: AppSpacing.md),
                ...detail.dataSeries.map(
                  (series) => _SourceCard(series: series),
                ),
              ],

              if (detail.outlook20Years != null ||
                  detail.outlook50Years != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  key: _outlookKey,
                  'このまま進んだら？',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (detail.outlook20Years != null)
                  _OutlookCard(
                    label: '20年後',
                    year: '2046年ごろ',
                    icon: Icons.hourglass_bottom,
                    text: detail.outlook20Years!,
                  ),
                if (detail.outlook50Years != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _OutlookCard(
                    label: '50年後',
                    year: '2076年ごろ',
                    icon: Icons.hourglass_disabled,
                    text: detail.outlook50Years!,
                  ),
                ],
              ],

              if (challenge.generationAgreement.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  key: _agreementKey,
                  '世代別の賛同度',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _GenerationAgreementMap(
                  generationAgreement: challenge.generationAgreement,
                  color: color,
                ),
              ],

              KeyedSubtree(
                key: _dietBillKey,
                child: _DietBillSection(
                  challengeId: challenge.id,
                  color: color,
                ),
              ),

              KeyedSubtree(
                key: _advocateKey,
                child: _IssueAdvocateSection(
                  challengeId: challenge.id,
                  color: color,
                ),
              ),

              KeyedSubtree(
                key: _agencyContactKey,
                child: _AgencyContactSection(
                  challengeId: challenge.id,
                  color: color,
                ),
              ),

              if (intlComparison != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  key: _intlKey,
                  children: [
                    const Icon(
                      Icons.public,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '世界との比較',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                InternationalComparisonSection(comparison: intlComparison),
              ],

              const SizedBox(height: AppSpacing.lg),
              _AgreeSection(
                challengeId: challenge.id,
                initialAgreeCount: challenge.agreeCount,
                color: color,
              ),

              const SizedBox(height: AppSpacing.lg),
              Text(
                key: _policyKey,
                'あなたなら、どの対策案を選ぶ？',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '投票数はみんなに公開されます',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PolicyOptionsSection(
                challengeId: challenge.id,
                challengeName: challenge.name,
                color: color,
              ),

              const SizedBox(height: AppSpacing.lg),
              Text(
                key: _commentsKey,
                'みんなの声',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _CommentSection(challengeId: challenge.id),
            ],
          );
        },
      ),
    );
  }
}

class _GenerationAgreementMap extends StatelessWidget {
  final Map<String, double> generationAgreement;
  final Color color;

  const _GenerationAgreementMap({
    required this.generationAgreement,
    required this.color,
  });

  static const _order = ['20s', '30s', '40s', '50s', '60s+'];
  static const _labels = {
    '20s': '20代',
    '30s': '30代',
    '40s': '40代',
    '50s': '50代',
    '60s+': '60代以上',
  };

  @override
  Widget build(BuildContext context) {
    final entries = _order
        .where((key) => generationAgreement.containsKey(key))
        .map((key) => MapEntry(key, generationAgreement[key]!))
        .toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    final maxEntry = entries.reduce((a, b) => a.value > b.value ? a : b);

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
          for (final entry in entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      _labels[entry.key] ?? entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value,
                        minHeight: 14,
                        backgroundColor: AppColors.background,
                        valueColor: AlwaysStoppedAnimation(
                          entry.key == maxEntry.key
                              ? color
                              : color.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${(entry.value * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Text(
            '「これは問題」と回答した人のうち、最も賛同度が高いのは${_labels[maxEntry.key]}です。',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DietBillSection extends ConsumerWidget {
  final String challengeId;
  final Color color;

  const _DietBillSection({required this.challengeId, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(dietBillsProvider(challengeId));

    return billsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (bills) {
        if (bills.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(Icons.account_balance, size: 16, color: color),
                const SizedBox(width: 6),
                const Text(
                  '国会での関連する動き',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...bills.map((bill) => _DietBillCard(bill: bill, color: color)),
          ],
        );
      },
    );
  }
}

class _DietBillCard extends StatelessWidget {
  final DietBill bill;
  final Color color;

  const _DietBillCard({required this.bill, required this.color});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bill.billName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.badge),
            ),
            child: Text(
              bill.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          GlossaryText(
            bill.summary,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.badge),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.insights,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GlossaryText(
                    bill.effect,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${bill.sourceLabel}（${bill.asOfDate}）',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(bill.sourceUrl),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('詳細を見る'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IssueAdvocateSection extends ConsumerWidget {
  final String challengeId;
  final Color color;

  const _IssueAdvocateSection({required this.challengeId, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advocatesAsync = ref.watch(issueAdvocatesProvider(challengeId));

    return advocatesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (advocates) {
        if (advocates.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(Icons.campaign_outlined, size: 16, color: color),
                const SizedBox(width: 6),
                const Text(
                  '政党・個人が挙げている主張',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              '一次資料で裏取りできた立場のみを掲載しています',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...advocates.map(
              (advocate) => _AdvocateCard(advocate: advocate, color: color),
            ),
          ],
        );
      },
    );
  }
}

class _AdvocateCard extends StatelessWidget {
  final IssueAdvocate advocate;
  final Color color;

  const _AdvocateCard({required this.advocate, required this.color});

  static const _typeLabels = {
    'party': '政党',
    'government': '政府・与党',
    'individual': '個人',
  };

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: Text(
                  _typeLabels[advocate.type] ?? advocate.type,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  advocate.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GlossaryText(
            advocate.stance,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${advocate.sourceLabel}（${advocate.asOfDate}）',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(advocate.sourceUrl),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('詳細を見る'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgencyContactSection extends ConsumerWidget {
  final String challengeId;
  final Color color;

  const _AgencyContactSection({required this.challengeId, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(agencyContactsProvider(challengeId));

    return contactsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (contacts) {
        if (contacts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(Icons.mark_email_read_outlined, size: 16, color: color),
                const SizedBox(width: 6),
                const Text(
                  '運営者から関係省庁・窓口への問い合わせ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              '実際に問い合わせを行った記録のみ掲載しています',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...contacts.map(
              (contact) => _AgencyContactCard(contact: contact, color: color),
            ),
          ],
        );
      },
    );
  }
}

class _AgencyContactCard extends StatelessWidget {
  final AgencyContact contact;
  final Color color;

  const _AgencyContactCard({required this.contact, required this.color});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contact.agencyName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: Text(
                  contact.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                contact.method,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GlossaryText(
            contact.summary,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          if (contact.responseSummary != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.badge),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.reply,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: GlossaryText(
                      contact.responseSummary!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            contact.contactDate,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _AgreeSection extends ConsumerStatefulWidget {
  final String challengeId;
  final int initialAgreeCount;
  final Color color;

  const _AgreeSection({
    required this.challengeId,
    required this.initialAgreeCount,
    required this.color,
  });

  @override
  ConsumerState<_AgreeSection> createState() => _AgreeSectionState();
}

class _AgreeSectionState extends ConsumerState<_AgreeSection> {
  late int _agreeCount = widget.initialAgreeCount;
  bool _agreed = false;

  Future<void> _onAgree() async {
    if (_agreed) return;
    final result = await ref.read(
      agreeChallengeProvider(widget.challengeId).future,
    );
    if (result && mounted) {
      setState(() {
        _agreeCount++;
        _agreed = true;
      });
      ref
          .read(agreedChallengeIdsProvider.notifier)
          .update((ids) => {...ids, widget.challengeId});
      AnalyticsService().logAgreeSubmitted(challengeId: widget.challengeId);
      final newlyUnlocked = await CheckNewAchievements.call(
        () => ActivityStore().addVotedChallenge(widget.challengeId),
      );
      if (newlyUnlocked.isNotEmpty && mounted) {
        showAchievementUnlockDialogs(context, newlyUnlocked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _agreed ? null : _onAgree,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: _agreed ? AppColors.border : widget.color),
          foregroundColor: _agreed ? AppColors.textMuted : widget.color,
        ),
        child: Text(
          _agreed ? '賛同済み ✓ ($_agreeCount)' : 'これは問題 ($_agreeCount)',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _PolicyOptionsSection extends ConsumerWidget {
  final String challengeId;
  final String challengeName;
  final Color color;

  const _PolicyOptionsSection({
    required this.challengeId,
    required this.challengeName,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(policyOptionsProvider(challengeId));
    final selectedMap = ref.watch(selectedPolicyOptionIdsProvider);
    final selectedOptionId = selectedMap[challengeId];

    return optionsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => const Text(
        '対策案を読み込めませんでした',
        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      data: (options) {
        if (options.isEmpty) return const SizedBox.shrink();

        final totalVotes = options.fold<int>(0, (sum, o) => sum + o.voteCount);
        final maxVotes = options
            .map((o) => o.voteCount)
            .reduce((a, b) => a > b ? a : b);
        final hasVoted = selectedOptionId != null;

        return Column(
          children: [
            ...options.map(
              (option) => _PolicyOptionCard(
                option: option,
                color: color,
                totalVotes: totalVotes,
                isTopVoted: option.voteCount == maxVotes && totalVotes > 0,
                isSelected: option.id == selectedOptionId,
                hasVoted: hasVoted,
                challengeId: challengeId,
              ),
            ),
            if (hasVoted) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _shareResult(
                    options: options,
                    selectedOptionId: selectedOptionId,
                    totalVotes: totalVotes,
                  ),
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: const Text('投票結果をシェアする'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _shareResult({
    required List<PolicyOption> options,
    required String selectedOptionId,
    required int totalVotes,
  }) async {
    final selected = options.firstWhere((o) => o.id == selectedOptionId);
    final resultLines = options
        .map((o) {
          final pct = totalVotes == 0
              ? 0
              : (o.voteCount / totalVotes * 100).round();
          final mark = o.id == selectedOptionId ? '✅' : '　';
          return '$mark ${o.title}: $pct%';
        })
        .join('\n');

    final text =
        '日本の未来マップ 対策案投票\n'
        '「$challengeName」について、私は\n'
        '「${selected.title}」を選びました\n\n'
        '【投票結果】\n'
        '$resultLines\n\n'
        'あなたならどれを選ぶ？';

    try {
      await Share.share(text);
      AnalyticsService().logContentShared(contentType: 'policy_option_result');
    } catch (_) {
      // シェアシートのキャンセル等は無視する
    }
  }
}

class _PolicyOptionCard extends ConsumerStatefulWidget {
  final PolicyOption option;
  final Color color;
  final int totalVotes;
  final bool isTopVoted;
  final bool isSelected;
  final bool hasVoted;
  final String challengeId;

  const _PolicyOptionCard({
    required this.option,
    required this.color,
    required this.totalVotes,
    required this.isTopVoted,
    required this.isSelected,
    required this.hasVoted,
    required this.challengeId,
  });

  @override
  ConsumerState<_PolicyOptionCard> createState() => _PolicyOptionCardState();
}

class _PolicyOptionCardState extends ConsumerState<_PolicyOptionCard> {
  bool _voting = false;

  Future<void> _vote() async {
    if (_voting || widget.hasVoted) return;
    setState(() => _voting = true);

    final result = await ref.read(
      votePolicyOptionProvider((
        challengeId: widget.challengeId,
        optionId: widget.option.id,
      )).future,
    );
    if (!mounted) return;
    setState(() => _voting = false);

    if (result) {
      AnalyticsService().logPolicyOptionVoted(
        challengeId: widget.challengeId,
        optionId: widget.option.id,
      );
      final newlyUnlocked = await CheckNewAchievements.call(
        () => ActivityStore().addPolicyVote(widget.challengeId),
      );
      if (newlyUnlocked.isNotEmpty && mounted) {
        showAchievementUnlockDialogs(context, newlyUnlocked);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('投票に失敗しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.totalVotes == 0
        ? 0.0
        : widget.option.voteCount / widget.totalVotes;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: widget.isSelected ? widget.color : AppColors.border,
          width: widget.isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.option.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (widget.isTopVoted) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.emoji_events,
                  size: 14,
                  color: AppColors.pensionOrange,
                ),
              ],
              if (widget.isSelected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle, size: 16, color: widget.color),
              ],
            ],
          ),
          const SizedBox(height: 6),
          GlossaryText(
            widget.option.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.badge),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.insights,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GlossaryText(
                    widget.option.expectedImpact,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (widget.hasVoted) ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 10,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation(
                        widget.isSelected
                            ? widget.color
                            : widget.color.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 68,
                  child: Text(
                    '${(percentage * 100).round()}% (${widget.option.voteCount})',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _voting ? null : _vote,
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.color,
                  side: BorderSide(color: widget.color),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: _voting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('この案を選ぶ'),
              ),
            ),
        ],
      ),
    );
  }
}

class _OutlookCard extends StatelessWidget {
  final String label;
  final String year;
  final IconData icon;
  final String text;

  const _OutlookCard({
    required this.label,
    required this.year,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.danger),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '（$year）',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GlossaryText(text, style: const TextStyle(fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }
}

class _ComparisonChart extends StatelessWidget {
  final List<ChallengeDataSeries> dataSeries;
  final Color color;

  const _ComparisonChart({required this.dataSeries, required this.color});

  @override
  Widget build(BuildContext context) {
    final lineColors = [color, AppColors.textMuted];
    final allValues = dataSeries
        .expand((series) => series.graphData.map((p) => p.value))
        .toList();
    final interval = niceAxisInterval(
      allValues.reduce((a, b) => a < b ? a : b),
      allValues.reduce((a, b) => a > b ? a : b),
    );
    // 軸ラベルは長い注釈付き単位（例: 「%（消滅可能性自治体の割合）」）だと
    // はみ出すため、括弧より前の短い単位表記のみを使う
    final unit = dataSeries.first.unit.split('（').first.split('(').first.trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: interval,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toStringAsFixed(0)}$unit',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final points = dataSeries.first.graphData;
                        final idx = value.round();
                        if (idx < 0 || idx >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${points[idx].year}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: dataSeries.asMap().entries.map((entry) {
                  final series = entry.value;
                  return LineChartBarData(
                    spots: series.graphData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                        .toList(),
                    isCurved: true,
                    color: lineColors[entry.key % lineColors.length],
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    dashArray: series.sourceType == 'official' ? null : [6, 4],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: dataSeries.asMap().entries.map((entry) {
              final series = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 3,
                      color: lineColors[entry.key % lineColors.length],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      series.sourceType == 'official' ? '公式' : '民間',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final ChallengeDataSeries series;

  const _SourceCard({required this.series});

  @override
  Widget build(BuildContext context) {
    final isOfficial = series.sourceType == 'official';

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isOfficial
                      ? AppColors.primaryLight
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isOfficial ? '公式' : '民間',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isOfficial
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  series.source,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (series.note != null) ...[
            const SizedBox(height: 6),
            Text(
              series.note!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentSection extends ConsumerStatefulWidget {
  final String challengeId;

  const _CommentSection({required this.challengeId});

  @override
  ConsumerState<_CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<_CommentSection> {
  final _controller = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _controller.text.trim();
    if (_posting) return;

    final validationError = ValidateComment.call(text);
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    setState(() => _posting = true);
    final result = await ref.read(
      postCommentProvider((challengeId: widget.challengeId, text: text)).future,
    );
    if (!mounted) return;
    setState(() => _posting = false);

    if (result) {
      AnalyticsService().logCommentPosted(challengeId: widget.challengeId);
      final newlyUnlocked = await CheckNewAchievements.call(
        () => ActivityStore().incrementCommentsPosted(),
      );
      _controller.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      if (newlyUnlocked.isNotEmpty && mounted) {
        showAchievementUnlockDialogs(context, newlyUnlocked);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('コメントの投稿に失敗しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.challengeId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLength: 140,
                decoration: const InputDecoration(
                  hintText: 'この課題について思うことを一言...',
                  isDense: true,
                  counterText: '',
                ),
                onSubmitted: (_) => _post(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              onPressed: _posting ? null : _post,
              icon: _posting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, size: 18),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        commentsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => const Text(
            'コメントを読み込めませんでした',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          data: (comments) {
            if (comments.isEmpty) {
              final isOnline =
                  ref.watch(connectivityProvider).valueOrNull ?? true;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  isOnline
                      ? 'まだコメントはありません。最初の声を届けてみましょう。'
                      : 'オフラインのため最新のコメントを取得できません。',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            }
            final blockedIds = ref.watch(blockedUserIdsProvider);
            // いいねが多い順→新しい順で並べ、人気のコメントが埋もれないようにする
            final sorted =
                [...comments.where((c) => !blockedIds.contains(c.userId))]
                  ..sort((a, b) {
                    final byLikes = b.likeCount.compareTo(a.likeCount);
                    if (byLikes != 0) return byLikes;
                    return b.createdAt.compareTo(a.createdAt);
                  });
            return Column(
              children: sorted
                  .map(
                    (c) => _CommentTile(
                      comment: c,
                      challengeId: widget.challengeId,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CommentTile extends ConsumerWidget {
  final Comment comment;
  final String challengeId;

  const _CommentTile({required this.comment, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedIds = ref.watch(likedCommentIdsProvider);
    final liked = likedIds.contains(comment.id);
    final isPopular = comment.likeCount >= 3;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isPopular ? AppColors.primaryLight : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular) ...[
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 2),
                Text(
                  '人気のコメント',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Text(comment.text, style: const TextStyle(fontSize: 13, height: 1.5)),
          const SizedBox(height: 4),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.badge),
                onTap: liked
                    ? null
                    : () => ref
                          .read(
                            likeCommentProvider((
                              challengeId: challengeId,
                              commentId: comment.id,
                            )).future,
                          )
                          .then((success) {
                            if (success) {
                              AnalyticsService().logCommentLiked(
                                challengeId: challengeId,
                              );
                            }
                          }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: liked ? AppColors.danger : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.likeCount}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: liked ? AppColors.danger : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              UgcActionMenu(
                contentType: 'comment',
                contentId: comment.id,
                challengeId: challengeId,
                authorUserId: comment.userId,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionJumpBar extends StatelessWidget {
  final Color color;
  final VoidCallback onDataTap;
  final VoidCallback onOutlookTap;
  final VoidCallback onAgreementTap;
  final VoidCallback? onDietBillTap;
  final VoidCallback? onAdvocateTap;
  final VoidCallback? onAgencyContactTap;
  final VoidCallback? onIntlTap;
  final VoidCallback onPolicyTap;
  final VoidCallback onCommentsTap;

  const _SectionJumpBar({
    required this.color,
    required this.onDataTap,
    required this.onOutlookTap,
    required this.onAgreementTap,
    required this.onDietBillTap,
    required this.onAdvocateTap,
    required this.onAgencyContactTap,
    required this.onIntlTap,
    required this.onPolicyTap,
    required this.onCommentsTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_JumpItem>[
      _JumpItem('データ', Icons.bar_chart, onDataTap),
      _JumpItem('将来', Icons.hourglass_bottom, onOutlookTap),
      _JumpItem('賛同度', Icons.groups_outlined, onAgreementTap),
      if (onDietBillTap != null)
        _JumpItem('国会', Icons.account_balance, onDietBillTap!),
      if (onAdvocateTap != null)
        _JumpItem('政党・個人', Icons.campaign_outlined, onAdvocateTap!),
      if (onAgencyContactTap != null)
        _JumpItem('問い合わせ', Icons.mark_email_read_outlined, onAgencyContactTap!),
      if (onIntlTap != null) _JumpItem('世界', Icons.public, onIntlTap!),
      _JumpItem('対策案', Icons.how_to_vote_outlined, onPolicyTap),
      _JumpItem('声', Icons.forum_outlined, onCommentsTap),
    ];

    return Container(
      height: 44,
      alignment: Alignment.centerLeft,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final item = items[index];
          return ActionChip(
            avatar: Icon(item.icon, size: 14, color: color),
            label: Text(item.label, style: const TextStyle(fontSize: 12)),
            onPressed: item.onTap,
            backgroundColor: color.withValues(alpha: 0.08),
            side: BorderSide(color: color.withValues(alpha: 0.2)),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}

class _JumpItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _JumpItem(this.label, this.icon, this.onTap);
}
