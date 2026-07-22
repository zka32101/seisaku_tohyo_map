class User {
  final String uid;
  final int age;
  final String occupation; // student/office_worker/self_employed/retired/other
  final String region; // 都道府県コード
  final DateTime createdAt;
  final bool isPremium;
  final List<String> votedChallenges;
  final int agreeCount;

  User({
    required this.uid,
    required this.age,
    required this.occupation,
    required this.region,
    required this.createdAt,
    this.isPremium = false,
    this.votedChallenges = const [],
    this.agreeCount = 0,
  });

  User copyWith({
    String? uid,
    int? age,
    String? occupation,
    String? region,
    DateTime? createdAt,
    bool? isPremium,
    List<String>? votedChallenges,
    int? agreeCount,
  }) {
    return User(
      uid: uid ?? this.uid,
      age: age ?? this.age,
      occupation: occupation ?? this.occupation,
      region: region ?? this.region,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
      votedChallenges: votedChallenges ?? this.votedChallenges,
      agreeCount: agreeCount ?? this.agreeCount,
    );
  }

  @override
  String toString() =>
      'User(uid: $uid, age: $age, occupation: $occupation, region: $region)';
}
