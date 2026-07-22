class GlossaryTerm {
  final String id;
  final String term;
  final String reading; // ふりがな（検索用）
  final String definition;
  final String category; // economy/welfare/demographic/politics/debt/general

  const GlossaryTerm({
    required this.id,
    required this.term,
    required this.reading,
    required this.definition,
    required this.category,
  });
}
