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
  Future<void> addVotedChallenge(String challengeId) =>
      _addToSet('votedChallengeIds', challengeId);

  // 提案への投票
  Set<String> get votedProposalIds => _stringSet('votedProposalIds');
  Future<void> addVotedProposal(String proposalId) =>
      _addToSet('votedProposalIds', proposalId);

  // 自分が投稿した課題提案
  Set<String> get submittedProposalIds => _stringSet('submittedProposalIds');
  Future<void> addSubmittedProposal(String proposalId) =>
      _addToSet('submittedProposalIds', proposalId);

  // 対策案への投票（課題ID単位でユニークにカウント）
  Set<String> get policyVotedChallengeIds =>
      _stringSet('policyVotedChallengeIds');
  Future<void> addPolicyVote(String challengeId) =>
      _addToSet('policyVotedChallengeIds', challengeId);

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
    );
  }
}
