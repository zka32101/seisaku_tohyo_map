import 'package:firebase_analytics/firebase_analytics.dart';

/// アプリ内のKPIイベント計測をまとめて扱うサービス
///
/// Firebase未初期化（widgetテスト環境など）でも例外でアプリの動作を止めないよう、
/// 取得・送信の両方を防御的に行う。
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  FirebaseAnalytics? get _analytics {
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  Future<void> _log(String name, Map<String, Object> parameters) async {
    try {
      await _analytics?.logEvent(name: name, parameters: parameters);
    } catch (_) {
      // 計測の失敗はアプリの動作に影響させない
    }
  }

  Future<void> logLossCalculated({
    required int age,
    required double lossAmount,
  }) {
    return _log('loss_calculated', {'age': age, 'loss_amount': lossAmount});
  }

  Future<void> logVoteSubmitted({required String challengeId}) {
    return _log('vote_submitted', {'challenge_id': challengeId});
  }

  Future<void> logAgreeSubmitted({required String challengeId}) {
    return _log('agree_submitted', {'challenge_id': challengeId});
  }

  Future<void> logContentShared({required String contentType}) {
    return _log('content_shared', {'content_type': contentType});
  }

  Future<void> logCommentPosted({required String challengeId}) {
    return _log('comment_posted', {'challenge_id': challengeId});
  }

  Future<void> logCommentLiked({required String challengeId}) {
    return _log('comment_liked', {'challenge_id': challengeId});
  }

  Future<void> logPolicyOptionVoted({
    required String challengeId,
    required String optionId,
  }) {
    return _log('policy_option_voted', {
      'challenge_id': challengeId,
      'option_id': optionId,
    });
  }

  Future<void> logQuizCompleted({
    required String diagnosisLevel,
    required double averageAccuracy,
    required bool isAdvanced,
  }) {
    return _log('quiz_completed', {
      'diagnosis_level': diagnosisLevel,
      'average_accuracy': averageAccuracy,
      'is_advanced': isAdvanced ? 1 : 0,
    });
  }

  Future<void> logSearchUsed({required String query}) {
    return _log('search_used', {'query': query});
  }

  Future<void> logDonationPurchased({required String productId}) {
    return _log('donation_purchased', {'product_id': productId});
  }
}
