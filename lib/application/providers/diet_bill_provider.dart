import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/diet_bill.dart';
import '../usecases/load_diet_bills.dart';

final dietBillsProvider = FutureProvider.family<List<DietBill>, String>((
  ref,
  challengeId,
) {
  return Future.value(LoadDietBills.forChallenge(challengeId));
});
