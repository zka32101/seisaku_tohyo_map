import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/challenge.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/policy_option.dart';
import '../../infrastructure/firebase/firebase_service.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../../infrastructure/local_storage/blocked_users_store.dart';
import '../usecases/load_policy_options.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

// ユーザーが設定した都道府県（端末ローカルに永続化、初期値はActivityStoreから復元）
final selectedPrefectureProvider = StateProvider<String?>(
  (ref) => ActivityStore().selectedPrefecture,
);

// 認証 UID を取得
final userIdProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(firebaseServiceProvider);
  final userId = service.getCurrentUserId();
  if (userId != null) {
    return userId;
  }
  // 未認証の場合は匿名サインイン
  return await service.signInAnonymously();
});

// 課題の賛同数再取得用トリガー（賛同後にインクリメントしてrefreshする）
final challengeAgreeCountsRefreshProvider = StateProvider<int>((ref) => 0);

// 課題一覧を取得（モックデータ + Firestoreに実際に書き込まれている賛同数をマージ）
final challengesProvider = FutureProvider<List<Challenge>>((ref) async {
  ref.watch(challengeAgreeCountsRefreshProvider);
  // 課題そのもの（説明文・カテゴリ等）は初期段階のためモックデータを使用するが、
  // 賛同数だけは実際にFirestoreへ書き込まれている値を反映する
  // （でなければ、賛同数はアプリを再起動するたびに0に戻ってしまう）
  final challenges = FirebaseService.getMockChallenges();
  final service = ref.watch(firebaseServiceProvider);
  final realAgreeCounts = await service.getChallengeAgreeCounts();
  final merged = realAgreeCounts.isEmpty
      ? challenges
      : challenges
            .map(
              (c) => c.copyWith(
                agreeCount: c.agreeCount + (realAgreeCounts[c.id] ?? 0),
              ),
            )
            .toList();

  // 「今週+N件」表示用のスナップショットを、必要な時だけ（週1回）更新する
  await ActivityStore().refreshAgreeCountSnapshotIfStale({
    for (final c in merged) c.id: c.agreeCount,
  });

  return merged;
});

// このセッションで「これは問題」に賛同した課題ID（おすすめ機能に利用）
final agreedChallengeIdsProvider = StateProvider<Set<String>>((ref) => {});

// 一覧画面で選択中のカテゴリフィルター（nullは「すべて」）
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

// 一覧画面の検索キーワード
final searchQueryProvider = StateProvider<String>((ref) => '');

// 課題に賛同
final agreeChallengeProvider = FutureProvider.family<bool, String>((
  ref,
  challengeId,
) async {
  final service = ref.watch(firebaseServiceProvider);
  final userId = await ref.read(userIdProvider.future);

  if (userId == null) return false;

  final result = await service.agreeChallenge(
    userId,
    challengeId,
    prefecture: ActivityStore().selectedPrefecture,
  );
  if (result) {
    ref.read(challengeAgreeCountsRefreshProvider.notifier).state++;
  }
  return result;
});

// 指定した課題について、自分と同じ都道府県からの賛同がどれくらいの割合かを取得する
// （都道府県を設定していない場合はnull）
final prefectureAgreeStatsProvider =
    FutureProvider.family<({int total, int fromPrefecture})?, String>((
      ref,
      challengeId,
    ) async {
      final prefecture = ActivityStore().selectedPrefecture;
      if (prefecture == null) return null;
      final service = ref.watch(firebaseServiceProvider);
      return await service.getPrefectureAgreeStats(challengeId, prefecture);
    });

// 自分のコメントに新しくついた「未読」の返信数（マイページのバッジ表示用）。
// コメント投稿時に記録しておいた「自分が投稿したことのある課題」だけを対象に、
// 現在の返信数と最後に確認した時点の返信数の差分を合計する。
final myUnseenReplyCountProvider = FutureProvider<int>((ref) async {
  final myUserId = await ref.read(userIdProvider.future);
  if (myUserId == null) return 0;

  final challengeIds = ActivityStore().commentedChallengeIds;
  if (challengeIds.isEmpty) return 0;

  final service = ref.watch(firebaseServiceProvider);
  final seenCounts = ActivityStore().seenReplyCounts;
  // 各課題のコメント取得は互いに独立しているため、直列にawaitせず並列に取得する
  final commentLists = await Future.wait(
    challengeIds.map((challengeId) => service.getComments(challengeId)),
  );
  var unseen = 0;
  for (final comments in commentLists) {
    for (final comment in comments) {
      if (comment.userId != myUserId || comment.replyCount == 0) continue;
      final seen = seenCounts[comment.id] ?? 0;
      if (comment.replyCount > seen) {
        unseen += comment.replyCount - seen;
      }
    }
  }
  return unseen;
});

// 自分が投稿したコメント一覧（返信も含む）。「投票の記録」画面で投票メモと
// 合わせて振り返れるタイムラインを作るために使う。
final myCommentsTimelineProvider = FutureProvider<List<Comment>>((ref) async {
  final myUserId = await ref.read(userIdProvider.future);
  if (myUserId == null) return [];

  final challengeIds = ActivityStore().commentedChallengeIds;
  if (challengeIds.isEmpty) return [];

  final service = ref.watch(firebaseServiceProvider);
  final commentLists = await Future.wait(
    challengeIds.map((challengeId) => service.getComments(challengeId)),
  );
  return commentLists
      .expand((comments) => comments)
      .where((c) => c.userId == myUserId)
      .toList();
});

// 未読の返信をすべて「確認済み」にする（マイページのバッジをタップした時に呼ぶ）
Future<void> markAllRepliesSeen(WidgetRef ref) async {
  final myUserId = await ref.read(userIdProvider.future);
  if (myUserId == null) return;

  final service = ref.read(firebaseServiceProvider);
  final challengeIds = ActivityStore().commentedChallengeIds;
  final commentLists = await Future.wait(
    challengeIds.map((challengeId) => service.getComments(challengeId)),
  );
  for (final comments in commentLists) {
    for (final comment in comments) {
      if (comment.userId == myUserId && comment.replyCount > 0) {
        await ActivityStore().markReplySeen(comment.id, comment.replyCount);
      }
    }
  }
  ref.invalidate(myUnseenReplyCountProvider);
}

// コメント再取得用のトリガー（投稿後にインクリメントしてrefreshする）
final commentsRefreshProvider = StateProvider<int>((ref) => 0);

// 課題のコメント一覧
final commentsProvider = FutureProvider.family<List<Comment>, String>((
  ref,
  challengeId,
) async {
  ref.watch(commentsRefreshProvider);
  final service = ref.watch(firebaseServiceProvider);
  return await service.getComments(challengeId);
});

// コメント投稿（parentIdを指定すると返信として投稿される）
final postCommentProvider =
    FutureProvider.family<
      bool,
      ({String challengeId, String text, String? parentId})
    >((ref, params) async {
      final service = ref.watch(firebaseServiceProvider);
      // 匿名認証が完了する前に書き込むと Firestore ルールで拒否されるため、
      // vote/agree と同様にまず認証の完了を待つ
      final userId = await ref.read(userIdProvider.future);
      if (userId == null) return false;

      final result = await service.postComment(
        userId,
        params.challengeId,
        params.text,
        parentId: params.parentId,
      );
      if (result) {
        ref.read(commentsRefreshProvider.notifier).state++;
      }
      return result;
    });

// コメントの削除（投稿者本人のみ）
final deleteCommentProvider =
    FutureProvider.family<bool, ({String challengeId, String commentId})>((
      ref,
      params,
    ) async {
      final service = ref.watch(firebaseServiceProvider);
      final result = await service.deleteComment(
        params.challengeId,
        params.commentId,
      );
      if (result) {
        ref.read(commentsRefreshProvider.notifier).state++;
      }
      return result;
    });

// 不適切な投稿の通報
final reportContentProvider =
    FutureProvider.family<
      bool,
      ({
        String contentType,
        String contentId,
        String? challengeId,
        String? reason,
      })
    >((ref, params) async {
      final service = ref.watch(firebaseServiceProvider);
      final userId = await ref.read(userIdProvider.future);
      if (userId == null) return false;

      return await service.reportContent(
        userId: userId,
        contentType: params.contentType,
        contentId: params.contentId,
        challengeId: params.challengeId,
        reason: params.reason,
      );
    });

// ブロックしたユーザーID一覧（端末ローカルに保存、投稿の非表示に使用）
final blockedUserIdsProvider =
    StateNotifierProvider<BlockedUserIdsNotifier, Set<String>>(
      (ref) => BlockedUserIdsNotifier(),
    );

class BlockedUserIdsNotifier extends StateNotifier<Set<String>> {
  BlockedUserIdsNotifier() : super(BlockedUsersStore.getAll()) {
    _load();
  }

  Future<void> _load() async {
    await BlockedUsersStore.init();
    state = BlockedUsersStore.getAll();
  }

  Future<void> block(String userId) async {
    await BlockedUsersStore.add(userId);
    state = BlockedUsersStore.getAll();
  }
}

// このセッションでいいねしたコメントID
final likedCommentIdsProvider = StateProvider<Set<String>>((ref) => {});

// コメントへのいいね
final likeCommentProvider =
    FutureProvider.family<bool, ({String challengeId, String commentId})>((
      ref,
      params,
    ) async {
      final service = ref.watch(firebaseServiceProvider);
      final userId = await ref.read(userIdProvider.future);
      if (userId == null) return false;

      final result = await service.likeComment(
        userId,
        params.challengeId,
        params.commentId,
      );
      if (result) {
        ref
            .read(likedCommentIdsProvider.notifier)
            .update((ids) => {...ids, params.commentId});
        ref.read(commentsRefreshProvider.notifier).state++;
      }
      return result;
    });

// 対策案の再取得トリガー（投票後にインクリメントしてrefreshする）
final policyOptionsRefreshProvider = StateProvider<int>((ref) => 0);

// 課題ごとの対策案一覧（ベースデータ + Firestoreの実投票数を合算）
final policyOptionsProvider = FutureProvider.family<List<PolicyOption>, String>(
  (ref, challengeId) async {
    ref.watch(policyOptionsRefreshProvider);
    final baseline = LoadPolicyOptions.forChallenge(challengeId);
    if (baseline.isEmpty) return [];

    final service = ref.watch(firebaseServiceProvider);
    final extraVotes = await service.getPolicyOptionExtraVotes(challengeId);

    return baseline
        .map(
          (option) => option.copyWith(
            voteCount: option.voteCount + (extraVotes[option.id] ?? 0),
          ),
        )
        .toList();
  },
);

// 全課題の対策案を横断して集計したもの（対策案ランキング表示用）
final allPolicyOptionsProvider = FutureProvider<List<PolicyOption>>((
  ref,
) async {
  final results = await Future.wait(
    LoadPolicyOptions.challengeIds.map(
      (id) => ref.watch(policyOptionsProvider(id).future),
    ),
  );
  return results.expand((options) => options).toList();
});

// このセッションで選択した対策案（課題ID→対策案ID）
final selectedPolicyOptionIdsProvider = StateProvider<Map<String, String>>(
  (ref) => {},
);

// 対策案への投票
final votePolicyOptionProvider =
    FutureProvider.family<bool, ({String challengeId, String optionId})>((
      ref,
      params,
    ) async {
      final service = ref.watch(firebaseServiceProvider);
      final userId = await ref.read(userIdProvider.future);
      if (userId == null) return false;

      final result = await service.votePolicyOption(
        userId,
        params.challengeId,
        params.optionId,
      );
      if (result) {
        ref
            .read(selectedPolicyOptionIdsProvider.notifier)
            .update((map) => {...map, params.challengeId: params.optionId});
        ref.read(policyOptionsRefreshProvider.notifier).state++;
      }
      return result;
    });
