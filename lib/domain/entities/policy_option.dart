class PolicyOption {
  final String id;
  final String challengeId;
  final String title;
  final String description;
  final String expectedImpact; // 想定される効果・影響
  final int voteCount;

  PolicyOption({
    required this.id,
    required this.challengeId,
    required this.title,
    required this.description,
    required this.expectedImpact,
    this.voteCount = 0,
  });

  PolicyOption copyWith({int? voteCount}) {
    return PolicyOption(
      id: id,
      challengeId: challengeId,
      title: title,
      description: description,
      expectedImpact: expectedImpact,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}
