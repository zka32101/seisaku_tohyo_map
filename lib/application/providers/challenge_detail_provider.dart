import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/challenge_data.dart';
import '../usecases/load_challenge_detail.dart';

final challengeDetailProvider = FutureProvider.family<ChallengeDetail, String>((
  ref,
  challengeId,
) {
  return Future.value(LoadChallengeDetail.call(challengeId));
});
