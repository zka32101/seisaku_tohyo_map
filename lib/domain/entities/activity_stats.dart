/// マイページ・実績バッジ判定に使う活動統計のスナップショット
class ActivityStats {
  final int votedChallengeCount;
  final int votedProposalCount;
  final int submittedProposalCount;
  final int policyVoteCount;
  final int commentsPostedCount;
  final int quizzesCompletedCount;
  final int donationCount;
  final bool hasCalculatedPension;

  const ActivityStats({
    required this.votedChallengeCount,
    required this.votedProposalCount,
    required this.submittedProposalCount,
    required this.policyVoteCount,
    required this.commentsPostedCount,
    required this.quizzesCompletedCount,
    required this.donationCount,
    required this.hasCalculatedPension,
  });
}
