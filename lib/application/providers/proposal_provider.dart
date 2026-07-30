import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_proposal.dart';
import 'firebase_provider.dart';

// 提案一覧の再取得トリガー
final proposalsRefreshProvider = StateProvider<int>((ref) => 0);

// ユーザーからの課題提案一覧
final proposalsProvider = FutureProvider<List<UserProposal>>((ref) async {
  ref.watch(proposalsRefreshProvider);
  final service = ref.watch(firebaseServiceProvider);
  return service.getProposals();
});

// 課題提案の投稿（成功時は新規提案IDを返す）
final submitProposalProvider =
    FutureProvider.family<
      String?,
      ({String title, String description, String category})
    >((ref, params) async {
      final service = ref.watch(firebaseServiceProvider);
      final userId = await ref.read(userIdProvider.future);
      if (userId == null) return null;

      final proposalId = await service.submitProposal(
        userId: userId,
        title: params.title,
        description: params.description,
        category: params.category,
      );
      if (proposalId != null) {
        ref.read(proposalsRefreshProvider.notifier).state++;
      }
      return proposalId;
    });

// 課題提案の削除（投稿者本人のみ）
final deleteProposalProvider = FutureProvider.family<bool, String>((
  ref,
  proposalId,
) async {
  final service = ref.watch(firebaseServiceProvider);
  final result = await service.deleteProposal(proposalId);
  if (result) {
    ref.read(proposalsRefreshProvider.notifier).state++;
  }
  return result;
});

// このセッションで投票した提案ID
final votedProposalIdsProvider = StateProvider<Set<String>>((ref) => {});

// 課題提案への投票
final voteProposalProvider = FutureProvider.family<bool, String>((
  ref,
  proposalId,
) async {
  final service = ref.watch(firebaseServiceProvider);
  final userId = await ref.read(userIdProvider.future);
  if (userId == null) return false;

  final result = await service.voteProposal(userId, proposalId);
  if (result) {
    ref
        .read(votedProposalIdsProvider.notifier)
        .update((ids) => {...ids, proposalId});
    ref.read(proposalsRefreshProvider.notifier).state++;
  }
  return result;
});
