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
  Future<void> incrementCommentsPosted() => _increment('commentsPostedCount');

  int get quizzesCompletedCount => _count('quizzesCompletedCount');
  Future<void> incrementQuizzesCompleted() =>
      _increment('quizzesCompletedCount');

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

  Future<void> setVoteMemo(String challengeId, String memo) async {
    try {
      final memos = Map<String, String>.from(voteMemos);
      if (memo.trim().isEmpty) {
        memos.remove(challengeId);
      } else {
        memos[challengeId] = memo.trim();
      }
      await _box?.put('voteMemos', memos);
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
