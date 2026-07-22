import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/policy_scenario.dart';
import '../usecases/load_policy_simulation.dart';

final policySimulationsProvider = Provider<List<PolicySimulation>>((ref) {
  return LoadPolicySimulation.call();
});

// 選択中の指標ID（population / pension_reserve / national_debt）
final selectedIndicatorIdProvider = StateProvider<String>((ref) {
  return ref.watch(policySimulationsProvider).first.id;
});

final selectedSimulationProvider = Provider<PolicySimulation>((ref) {
  final simulations = ref.watch(policySimulationsProvider);
  final selectedId = ref.watch(selectedIndicatorIdProvider);
  return simulations.firstWhere(
    (s) => s.id == selectedId,
    orElse: () => simulations.first,
  );
});

// タイムマシンスライダーで選択中の年
final selectedYearProvider = StateProvider<int>((ref) {
  return ref.watch(policySimulationsProvider).first.minYear;
});
