import 'package:flutter/material.dart';

import '../../domain/entities/user_proposal.dart';
import '../theme/app_theme.dart';

/// 提案の運営への提出状況（未提出以外）を表示するバッジ。
/// 提案一覧・マイページの両方で使う共通ウィジェット。
class SubmissionStatusBadge extends StatelessWidget {
  final UserProposal proposal;

  const SubmissionStatusBadge({super.key, required this.proposal});

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
                if (proposal.submissionDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(proposal.submissionDate!),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
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

  static String _formatDate(DateTime d) => '${d.year}年${d.month}月${d.day}日';
}
