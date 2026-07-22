import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pension_calculation.dart';
import '../usecases/calculate_pension_loss.dart';

final pensionCalculationProvider =
    FutureProvider.family<PensionCalculation, int>((ref, age) {
      // 計算は同期的なので FutureProvider で wrap
      return Future.value(CalculatePensionLoss.call(age));
    });

// 現在のユーザー年齢を保持
final userAgeProvider = StateProvider<int?>((ref) => null);

// 選択された年齢での年金計算結果
final selectedPensionProvider = FutureProvider<PensionCalculation?>((ref) {
  final age = ref.watch(userAgeProvider);
  if (age == null) return Future.value(null);
  return Future.value(CalculatePensionLoss.call(age));
});
