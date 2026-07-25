class Challenge {
  final String id;
  final String name;
  final String description;
  final String category; // economy/welfare/demographic/politics/debt
  final int voteCount;
  final int agreeCount;
  final Map<String, double> generationAgreement; // 世代別賛同率
  final String status; // candidate/analyzing/published
  final DateTime createdAt;
  final List<String> tags; // 検索・発見用タグ（例: 年金, 子育て, 地方）
  // この課題に関連する国の予算区分の規模（兆円、参考値）。
  // 課題そのものへの予算配分ではなく、関連する予算区分（社会保障関係費・防衛関係費など）の
  // 規模を示す参考値。出典・時点が明確に確認できた課題のみ設定し、不明な課題はnullのまま。
  final double? budgetTrillionYen;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.voteCount,
    required this.agreeCount,
    required this.generationAgreement,
    required this.status,
    required this.createdAt,
    this.tags = const [],
    this.budgetTrillionYen,
  });

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? voteCount,
    int? agreeCount,
    Map<String, double>? generationAgreement,
    String? status,
    DateTime? createdAt,
    List<String>? tags,
    double? budgetTrillionYen,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      voteCount: voteCount ?? this.voteCount,
      agreeCount: agreeCount ?? this.agreeCount,
      generationAgreement: generationAgreement ?? this.generationAgreement,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      budgetTrillionYen: budgetTrillionYen ?? this.budgetTrillionYen,
    );
  }

  // 検索クエリが名前・説明・タグのいずれかに部分一致するか
  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();
    return name.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        tags.any((tag) => tag.toLowerCase().contains(q));
  }

  @override
  String toString() =>
      'Challenge(id: $id, name: $name, votes: $voteCount, agrees: $agreeCount)';
}
