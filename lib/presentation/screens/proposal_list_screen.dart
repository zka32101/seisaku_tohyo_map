import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../application/providers/proposal_provider.dart';
import '../../application/usecases/check_new_achievements.dart';
import '../../domain/entities/user_proposal.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_unlock_dialog.dart';
import '../widgets/ugc_action_menu.dart';
import 'submit_proposal_screen.dart';

class ProposalListScreen extends ConsumerWidget {
  const ProposalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(proposalsProvider);
    final blockedIds = ref.watch(blockedUserIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('みんなの提案')),
      body: proposalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (allProposals) {
          final proposals = allProposals
              .where((p) => !blockedIds.contains(p.userId))
              .toList();
          if (proposals.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'まだ提案がありません。\n気になる社会課題があれば、あなたが最初の提案者になりましょう！',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ),
            );
          }

          final promoted = proposals.where((p) => p.isPromoted).toList()
            ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
          final rest = proposals.where((p) => !p.isPromoted).toList()
            ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const Text(
                'あなたが気になる社会課題を提案し、みんなで投票しましょう。'
                '投票が集まった提案は「正式課題候補」として注目され、政府への提出も検討されます。',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (promoted.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '正式課題候補',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...promoted.map((p) => _ProposalCard(proposal: p)),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
              ],
              const Text(
                '投票受付中',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...rest.map((p) => _ProposalCard(proposal: p)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SubmitProposalScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('提案する'),
      ),
    );
  }
}

class _ProposalCard extends ConsumerStatefulWidget {
  final UserProposal proposal;

  const _ProposalCard({required this.proposal});

  @override
  ConsumerState<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends ConsumerState<_ProposalCard> {
  bool _voting = false;

  Future<void> _vote() async {
    if (_voting) return;
    setState(() => _voting = true);
    final result = await ref.read(
      voteProposalProvider(widget.proposal.id).future,
    );
    if (!mounted) return;
    setState(() => _voting = false);

    if (result) {
      final newlyUnlocked = await CheckNewAchievements.call(
        () => ActivityStore().addVotedProposal(widget.proposal.id),
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
    final votedIds = ref.watch(votedProposalIdsProvider);
    final voted = votedIds.contains(widget.proposal.id);
    final color = AppColors.categoryColor(widget.proposal.category);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: widget.proposal.isPromoted ? color : AppColors.border,
          width: widget.proposal.isPromoted ? 1.5 : 1,
        ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppColors.categoryIcon(widget.proposal.category),
                      size: 12,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppColors.categoryLabel(widget.proposal.category),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.how_to_vote, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${widget.proposal.voteCount}票',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              UgcActionMenu(
                contentType: 'proposal',
                contentId: widget.proposal.id,
                authorUserId: widget.proposal.userId,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.proposal.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            widget.proposal.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (widget.proposal.submissionStatus != SubmissionStatus.none) ...[
            const SizedBox(height: AppSpacing.sm),
            _SubmissionStatusBadge(proposal: widget.proposal),
          ],
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: voted ? null : (_voting ? null : _vote),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: AppColors.background,
                disabledForegroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: _voting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(voted ? '投票済み ✓' : 'この提案に投票する'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionStatusBadge extends StatelessWidget {
  final UserProposal proposal;

  const _SubmissionStatusBadge({required this.proposal});

  static const _statusColors = {
    SubmissionStatus.submitted: AppColors.primary,
    SubmissionStatus.responded: AppColors.pensionOrange,
    SubmissionStatus.adopted: AppColors.success,
    SubmissionStatus.declined: AppColors.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    final color =
        _statusColors[proposal.submissionStatus] ?? AppColors.textMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.campaign, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proposal.submissionStatus.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (proposal.submissionNote != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    proposal.submissionNote!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
