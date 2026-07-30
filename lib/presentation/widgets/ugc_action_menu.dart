import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../application/providers/proposal_provider.dart';
import '../theme/app_theme.dart';

/// ユーザー投稿（コメント・提案）に共通の「報告する／ブロック／削除」メニュー
///
/// [contentType] は 'comment' または 'proposal'。
/// [authorUserId] が自分のUIDと一致する場合のみ「削除」を表示し、
/// それ以外（＝他人の投稿）の場合のみ「報告する」「ブロック」を表示する。
class UgcActionMenu extends ConsumerWidget {
  final String contentType;
  final String contentId;
  final String? challengeId; // コメントの場合のみ必須
  final String? authorUserId;

  const UgcActionMenu({
    super.key,
    required this.contentType,
    required this.contentId,
    this.challengeId,
    this.authorUserId,
  });

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除しますか？'),
        content: const Text('この投稿を削除します。この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final bool result;
    if (contentType == 'comment') {
      result = await ref.read(
        deleteCommentProvider((
          challengeId: challengeId!,
          commentId: contentId,
        )).future,
      );
    } else {
      result = await ref.read(deleteProposalProvider(contentId).future);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result ? '削除しました' : '削除に失敗しました')));
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('この投稿を報告しますか？'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '不適切な内容として運営に報告します。内容を確認し、24時間以内に対応します。',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller,
              maxLength: 200,
              maxLines: 3,
              decoration: const InputDecoration(hintText: '理由（任意）'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('報告する'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await ref.read(
      reportContentProvider((
        contentType: contentType,
        contentId: contentId,
        challengeId: challengeId,
        reason: controller.text.trim().isEmpty ? null : controller.text.trim(),
      )).future,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result ? '報告を受け付けました' : '報告に失敗しました')),
    );
  }

  Future<void> _block(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('このユーザーをブロックしますか？'),
        content: const Text('ブロックすると、このユーザーの投稿がこの端末では表示されなくなります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ブロックする'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(blockedUserIdsProvider.notifier).block(authorUserId!);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ブロックしました')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(userIdProvider).valueOrNull;
    final isOwn =
        authorUserId != null &&
        currentUserId != null &&
        authorUserId == currentUserId;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16, color: AppColors.textMuted),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        switch (value) {
          case 'delete':
            _delete(context, ref);
            break;
          case 'report':
            _report(context, ref);
            break;
          case 'block':
            _block(context, ref);
            break;
        }
      },
      itemBuilder: (context) => [
        if (isOwn)
          const PopupMenuItem(value: 'delete', child: Text('削除する'))
        else ...[
          const PopupMenuItem(value: 'report', child: Text('報告する')),
          if (authorUserId != null)
            const PopupMenuItem(value: 'block', child: Text('このユーザーをブロック')),
        ],
      ],
    );
  }
}
