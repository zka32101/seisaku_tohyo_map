class DonationTier {
  final String productId; // Google Play Console / App Store Connect の商品IDと一致させる
  final String label;
  final String description;
  final String emoji;

  const DonationTier({
    required this.productId,
    required this.label,
    required this.description,
    required this.emoji,
  });

  static const List<DonationTier> all = [
    DonationTier(
      productId: 'donation_small',
      label: 'コーヒー1杯分',
      description: '気軽に応援したい方に',
      emoji: '☕',
    ),
    DonationTier(
      productId: 'donation_medium',
      label: 'ランチ1食分',
      description: 'もう少し応援したい方に',
      emoji: '🍱',
    ),
    DonationTier(
      productId: 'donation_large',
      label: 'がっつり応援',
      description: '継続的な開発をしっかり支えたい方に',
      emoji: '🎉',
    ),
  ];
}
