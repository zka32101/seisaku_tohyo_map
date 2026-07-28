import 'activity_stats.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool Function(ActivityStats stats) unlockedWhen;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.unlockedWhen,
  });

  bool isUnlockedBy(ActivityStats stats) => unlockedWhen(stats);
}

class Achievements {
  Achievements._();

  static final List<Achievement> all = [
    Achievement(
      id: 'first_diagnosis',
      title: 'はじめの一歩',
      description: '年金診断を1回受けた',
      emoji: '🌱',
      unlockedWhen: (s) => s.hasCalculatedPension,
    ),
    Achievement(
      id: 'first_vote',
      title: '声をあげた',
      description: '課題に1回「これは問題」で賛同した',
      emoji: '🗳️',
      unlockedWhen: (s) => s.votedChallengeCount >= 1,
    ),
    Achievement(
      id: 'vote_master',
      title: '賛同マスター',
      description: '10個の課題に「これは問題」で賛同した',
      emoji: '🏛️',
      unlockedWhen: (s) => s.votedChallengeCount >= 10,
    ),
    Achievement(
      id: 'voice_delivered',
      title: '声を届けた',
      description: 'コメントを1件投稿した',
      emoji: '💬',
      unlockedWhen: (s) => s.commentsPostedCount >= 1,
    ),
    Achievement(
      id: 'policy_expert',
      title: '政策通',
      description: '対策案に5回投票した',
      emoji: '📜',
      unlockedWhen: (s) => s.policyVoteCount >= 5,
    ),
    Achievement(
      id: 'quiz_master',
      title: 'クイズマスター',
      description: 'ギャップクイズを3回完了した',
      emoji: '🧠',
      unlockedWhen: (s) => s.quizzesCompletedCount >= 3,
    ),
    Achievement(
      id: 'proposer_debut',
      title: '提案者デビュー',
      description: '課題を1件提案した',
      emoji: '💡',
      unlockedWhen: (s) => s.submittedProposalCount >= 1,
    ),
    Achievement(
      id: 'supporter_of_proposals',
      title: '応援団',
      description: 'みんなの提案に5回投票した',
      emoji: '🤝',
      unlockedWhen: (s) => s.votedProposalCount >= 5,
    ),
    Achievement(
      id: 'donor',
      title: 'サポーター',
      description: '寄付で応援した',
      emoji: '☕',
      unlockedWhen: (s) => s.donationCount >= 1,
    ),
  ];
}
