import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/activity_stats.dart';

/// 端末ローカルに保存する、ユーザー自身の活動履歴（マイページ・実績バッジ用）
///
/// Firestore側は「誰が投票したか」を横断検索できるスキーマになっていないため
/// （votes/{userId}はドキュメント存在チェック専用で読み取り禁止）、
/// 「自分の活動」はこの端末内にHiveで保存する方式を採用している。
///
/// Hive未初期化（widgetテスト環境など）でも例外でアプリを止めないよう、
/// 全ての読み書きを防御的に行う。
class ActivityStore {
  static const _boxName = 'user_activity';
  static final ActivityStore _instance = ActivityStore._internal();
  static final Logger _logger = Logger();

  ActivityStore._internal();

  factory ActivityStore() => _instance;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox(_boxName);
    } catch (e) {
      _logger.e('Error initializing ActivityStore: $e');
    }
  }

  Box? get _box {
    try {
      return Hive.box(_boxName);
    } catch (e) {
      return null;
    }
  }

  Set<String> _stringSet(String key) {
    try {
      final raw = _box?.get(key, defaultValue: const <String>[]) as List?;
      return (raw ?? const <String>[]).cast<String>().toSet();
    } catch (e) {
      _logger.e('Error reading $key: $e');
      return {};
    }
  }

  Future<void> _addToSet(String key, String value) async {
    try {
      final set = _stringSet(key)..add(value);
      await _box?.put(key, set.toList());
    } catch (e) {
      _logger.e('Error writing $key: $e');
    }
  }

  int _count(String key) {
    try {
      return _box?.get(key, defaultValue: 0) as int? ?? 0;
    } catch (e) {
      _logger.e('Error reading $key: $e');
      return 0;
    }
  }

  Future<void> _increment(String key) async {
    try {
      await _box?.put(key, _count(key) + 1);
    } catch (e) {
      _logger.e('Error writing $key: $e');
    }
  }

  // 課題への投票
  Set<String> get votedChallengeIds => _stringSet('votedChallengeIds');
  Future<void> addVotedChallenge(String challengeId) async {
    await _addToSet('votedChallengeIds', challengeId);
    await _recordVoteActivity();
  }

  // 提案への投票
  Set<String> get votedProposalIds => _stringSet('votedProposalIds');
  Future<void> addVotedProposal(String proposalId) async {
    await _addToSet('votedProposalIds', proposalId);
    await _recordVoteActivity();
  }

  // 自分が投稿した課題提案
  Set<String> get submittedProposalIds => _stringSet('submittedProposalIds');
  Future<void> addSubmittedProposal(String proposalId) =>
      _addToSet('submittedProposalIds', proposalId);

  // 対策案への投票（課題ID単位でユニークにカウント）
  Set<String> get policyVotedChallengeIds =>
      _stringSet('policyVotedChallengeIds');
  Future<void> addPolicyVote(String challengeId) async {
    await _addToSet('policyVotedChallengeIds', challengeId);
    await _recordVoteActivity();
  }

  // ── 選んだ対策案そのもの（課題ID → 対策案ID）──
  // policyVotedChallengeIdsは「投票した」という事実のみを記録するため、
  // 政党との政策一致度を計算するには、実際に選んだ対策案IDが別途必要になる。
  Map<String, String> get selectedPolicyOptions {
    try {
      final raw =
          _box?.get('selectedPolicyOptions', defaultValue: const {}) as Map?;
      return (raw ?? const {}).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (e) {
      _logger.e('Error reading selectedPolicyOptions: $e');
      return {};
    }
  }

  Future<void> setSelectedPolicyOption(
    String challengeId,
    String optionId,
  ) async {
    try {
      final options = Map<String, String>.from(selectedPolicyOptions);
      options[challengeId] = optionId;
      await _box?.put('selectedPolicyOptions', options);
    } catch (e) {
      _logger.e('Error writing selectedPolicyOptions: $e');
    }
  }

  // ── 投票ストリーク（連続投票日数）──
  //
  // 「課題」「対策案」いずれかへの投票を1日1回以上行った日を「投票した日」として
  // カウントし、連続日数を記録する。深夜0時〜4時の投票は隠し実績「night_owl」用に
  // 別途フラグを立てる。

  static String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static bool _isNextDay(String previousKey, String currentKey) {
    try {
      final previous = DateTime.parse(previousKey);
      final current = DateTime.parse(currentKey);
      return current.difference(previous).inDays == 1;
    } catch (e) {
      return false;
    }
  }

  Future<void> _recordVoteActivity() async {
    try {
      final now = DateTime.now();
      final todayKey = _dateKey(now);
      final lastKey = _box?.get('lastVoteDateKey') as String?;

      if (now.hour < 4) {
        await _box?.put('hasVotedLateNight', true);
      }

      if (lastKey == todayKey) return; // 今日はすでにカウント済み

      final newStreak = (lastKey != null && _isNextDay(lastKey, todayKey))
          ? _count('currentVoteStreak') + 1
          : 1;

      await _box?.put('currentVoteStreak', newStreak);
      await _box?.put('lastVoteDateKey', todayKey);

      if (newStreak > _count('longestVoteStreak')) {
        await _box?.put('longestVoteStreak', newStreak);
      }
    } catch (e) {
      _logger.e('Error recording vote streak: $e');
    } finally {
      // ストリーク判定が早期returnする（同日2回目以降の投票）場合でも、
      // 週次ダイジェスト用のログは投票のたびに必ず記録する
      await _logActivity('vote');
    }
  }

  /// 表示用の現在の連続投票日数。
  /// 最後の投票が「今日」または「昨日」でない場合（2日以上空いた場合）は
  /// 実質的にストリークが途切れているため0を返す。
  int get voteStreakDays {
    final lastKey = _box?.get('lastVoteDateKey') as String?;
    if (lastKey == null) return 0;
    final todayKey = _dateKey(DateTime.now());
    if (lastKey == todayKey || _isNextDay(lastKey, todayKey)) {
      return _count('currentVoteStreak');
    }
    return 0;
  }

  int get longestVoteStreak => _count('longestVoteStreak');

  bool get hasVotedToday =>
      (_box?.get('lastVoteDateKey') as String?) == _dateKey(DateTime.now());

  bool get hasVotedLateNight {
    try {
      return _box?.get('hasVotedLateNight', defaultValue: false) as bool? ??
          false;
    } catch (e) {
      return false;
    }
  }

  // ── 都道府県設定（地域の関連課題表示用）──
  String? get selectedPrefecture {
    try {
      return _box?.get('selectedPrefecture') as String?;
    } catch (e) {
      _logger.e('Error reading selectedPrefecture: $e');
      return null;
    }
  }

  Future<void> setSelectedPrefecture(String prefecture) async {
    try {
      await _box?.put('selectedPrefecture', prefecture);
    } catch (e) {
      _logger.e('Error writing selectedPrefecture: $e');
    }
  }

  int get commentsPostedCount => _count('commentsPostedCount');
  Future<void> incrementCommentsPosted() async {
    await _increment('commentsPostedCount');
    await _logActivity('comment');
  }

  int get quizzesCompletedCount => _count('quizzesCompletedCount');
  Future<void> incrementQuizzesCompleted() async {
    await _increment('quizzesCompletedCount');
    await _logActivity('quiz');
  }

  int get donationCount => _count('donationCount');
  Future<void> incrementDonationCount() => _increment('donationCount');

  bool get hasCalculatedPension {
    try {
      return _box?.get('hasCalculatedPension', defaultValue: false) as bool? ??
          false;
    } catch (e) {
      _logger.e('Error reading hasCalculatedPension: $e');
      return false;
    }
  }

  Future<void> markPensionCalculated() async {
    try {
      await _box?.put('hasCalculatedPension', true);
    } catch (e) {
      _logger.e('Error writing hasCalculatedPension: $e');
    }
  }

  // コンテンツポリシー（不適切な投稿・迷惑ユーザーを許容しない旨）への同意
  bool get hasAcceptedContentPolicy {
    try {
      return _box?.get('hasAcceptedContentPolicy', defaultValue: false)
              as bool? ??
          false;
    } catch (e) {
      _logger.e('Error reading hasAcceptedContentPolicy: $e');
      return false;
    }
  }

  Future<void> markContentPolicyAccepted() async {
    try {
      await _box?.put('hasAcceptedContentPolicy', true);
    } catch (e) {
      _logger.e('Error writing hasAcceptedContentPolicy: $e');
    }
  }

  // ── 投票理由メモ（課題ID → 自分だけが見られる一言メモ）──
  // 後で自分の考えの変化を振り返れるように、賛同した課題ごとに任意のメモを残せる。
  Map<String, String> get voteMemos {
    try {
      final raw = _box?.get('voteMemos', defaultValue: const {}) as Map?;
      return (raw ?? const {}).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (e) {
      _logger.e('Error reading voteMemos: $e');
      return {};
    }
  }

  String? voteMemoFor(String challengeId) => voteMemos[challengeId];

  // メモを書いた（更新した）日時。「投票の記録」画面で新しい順に並べるために使う。
  Map<String, DateTime> get _voteMemoTimestamps {
    try {
      final raw =
          _box?.get('voteMemoTimestamps', defaultValue: const {}) as Map?;
      final result = <String, DateTime>{};
      for (final entry in (raw ?? const {}).entries) {
        final parsed = DateTime.tryParse(entry.value.toString());
        if (parsed != null) result[entry.key.toString()] = parsed;
      }
      return result;
    } catch (e) {
      _logger.e('Error reading voteMemoTimestamps: $e');
      return {};
    }
  }

  DateTime? voteMemoUpdatedAt(String challengeId) =>
      _voteMemoTimestamps[challengeId];

  Future<void> setVoteMemo(String challengeId, String memo) async {
    try {
      final memos = Map<String, String>.from(voteMemos);
      final timestamps = Map<String, String>.from(
        _voteMemoTimestamps.map(
          (key, value) => MapEntry(key, value.toIso8601String()),
        ),
      );
      if (memo.trim().isEmpty) {
        memos.remove(challengeId);
        timestamps.remove(challengeId);
      } else {
        memos[challengeId] = memo.trim();
        timestamps[challengeId] = DateTime.now().toIso8601String();
      }
      await _box?.put('voteMemos', memos);
      await _box?.put('voteMemoTimestamps', timestamps);
    } catch (e) {
      _logger.e('Error writing voteMemos: $e');
    }
  }

  // ── フォロー中の課題（国会・協力団体の動きを追いたい課題）──
  Set<String> get followedChallengeIds => _stringSet('followedChallengeIds');

  Future<void> toggleFollowedChallenge(String challengeId) async {
    final current = followedChallengeIds;
    if (current.contains(challengeId)) {
      final updated = current..remove(challengeId);
      await _box?.put('followedChallengeIds', updated.toList());
    } else {
      await _addToSet('followedChallengeIds', challengeId);
    }
  }

  // ── 自分がトップレベルコメントを投稿した課題（返信通知バッジ用）──
  // コメント自体はFirestore側にしか無く「誰が投稿したか」を横断検索できないため、
  // 「自分が投稿したことのある課題」だけを端末ローカルに覚えておき、
  // 返信チェック時にその課題だけを対象にコメント一覧を取得する。
  Set<String> get commentedChallengeIds => _stringSet('commentedChallengeIds');

  Future<void> addCommentedChallenge(String challengeId) =>
      _addToSet('commentedChallengeIds', challengeId);

  // 自分のコメントについて、最後に確認した時点の返信数（コメントID→返信数）。
  // 現在の返信数との差分が「未読の返信」としてバッジに表示される。
  Map<String, int> get seenReplyCounts {
    try {
      final raw = _box?.get('seenReplyCounts', defaultValue: const {}) as Map?;
      return (raw ?? const {}).map(
        (key, value) => MapEntry(key.toString(), value as int? ?? 0),
      );
    } catch (e) {
      _logger.e('Error reading seenReplyCounts: $e');
      return {};
    }
  }

  Future<void> markReplySeen(String commentId, int replyCount) async {
    try {
      final counts = Map<String, int>.from(seenReplyCounts);
      counts[commentId] = replyCount;
      await _box?.put('seenReplyCounts', counts);
    } catch (e) {
      _logger.e('Error writing seenReplyCounts: $e');
    }
  }

  // ── 今週の賛同数スナップショット（課題カードの「今週+N件」表示用）──
  // 賛同数の実数（Firestoreに書き込まれた値）は増える一方なので、7日ごとに
  // その時点の値を保存しておき、現在値との差分を「今週の伸び」として表示する。
  Map<String, int> get _agreeCountSnapshot {
    try {
      final raw =
          _box?.get('agreeCountSnapshot', defaultValue: const {}) as Map?;
      return (raw ?? const {}).map(
        (key, value) => MapEntry(key.toString(), value as int? ?? 0),
      );
    } catch (e) {
      _logger.e('Error reading agreeCountSnapshot: $e');
      return {};
    }
  }

  DateTime? get _agreeCountSnapshotDate {
    try {
      final raw = _box?.get('agreeCountSnapshotDate') as String?;
      return raw == null ? null : DateTime.tryParse(raw);
    } catch (e) {
      _logger.e('Error reading agreeCountSnapshotDate: $e');
      return null;
    }
  }

  /// スナップショットが無い、または7日以上前の場合、現在の賛同数で更新する。
  /// 課題一覧を開くたびに呼び出し、以降1週間はその時点の値を基準に
  /// 「今週+N件」の差分を計算する。
  Future<void> refreshAgreeCountSnapshotIfStale(
    Map<String, int> currentCounts,
  ) async {
    final snapshotDate = _agreeCountSnapshotDate;
    final isStale =
        snapshotDate == null ||
        DateTime.now().difference(snapshotDate).inDays >= 7;
    if (!isStale) return;
    try {
      await _box?.put('agreeCountSnapshot', currentCounts);
      await _box?.put(
        'agreeCountSnapshotDate',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      _logger.e('Error writing agreeCountSnapshot: $e');
    }
  }

  /// 今週の賛同数の伸び（スナップショット時点からの差分）。
  /// スナップショット時点でまだ存在しなかった課題（新規追加など）は
  /// 差分の基準が無いため0を返す。
  int weeklyAgreeDelta(String challengeId, int currentCount) {
    final snapshot = _agreeCountSnapshot;
    final baseline = snapshot[challengeId];
    if (baseline == null) return 0;
    final delta = currentCount - baseline;
    return delta > 0 ? delta : 0;
  }

  // ── 週次アクティビティログ（マイページの「今週の活動」ダイジェスト用）──
  // 各アクションの発生日時を軽量に記録し、直近7日間の件数だけを集計する。
  // 無限に増え続けないよう、末尾から一定件数だけを保持する。
  static const _maxActivityLogEntries = 500;

  Future<void> _logActivity(String type) async {
    try {
      final raw =
          _box?.get('activityLog', defaultValue: const <String>[]) as List?;
      final log = (raw ?? const <String>[]).cast<String>().toList();
      log.add('$type|${DateTime.now().toIso8601String()}');
      if (log.length > _maxActivityLogEntries) {
        log.removeRange(0, log.length - _maxActivityLogEntries);
      }
      await _box?.put('activityLog', log);
    } catch (e) {
      _logger.e('Error logging activity: $e');
    }
  }

  /// 直近7日間の、種類（vote/comment/quiz）ごとの活動件数
  Map<String, int> get weeklyActivityCounts {
    try {
      final raw =
          _box?.get('activityLog', defaultValue: const <String>[]) as List?;
      final log = (raw ?? const <String>[]).cast<String>();
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      final counts = <String, int>{};
      for (final entry in log) {
        final parts = entry.split('|');
        if (parts.length != 2) continue;
        final timestamp = DateTime.tryParse(parts[1]);
        if (timestamp == null || timestamp.isBefore(cutoff)) continue;
        counts[parts[0]] = (counts[parts[0]] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      _logger.e('Error reading weeklyActivityCounts: $e');
      return {};
    }
  }

  // 実績バッジ判定用のスナップショット（マイページ表示・新規解除の差分検出の両方に使う）
  ActivityStats currentStats() {
    return ActivityStats(
      votedChallengeCount: votedChallengeIds.length,
      votedProposalCount: votedProposalIds.length,
      submittedProposalCount: submittedProposalIds.length,
      policyVoteCount: policyVotedChallengeIds.length,
      commentsPostedCount: commentsPostedCount,
      quizzesCompletedCount: quizzesCompletedCount,
      donationCount: donationCount,
      hasCalculatedPension: hasCalculatedPension,
      voteStreakDays: voteStreakDays,
      longestVoteStreak: longestVoteStreak,
      hasVotedLateNight: hasVotedLateNight,
    );
  }
}
