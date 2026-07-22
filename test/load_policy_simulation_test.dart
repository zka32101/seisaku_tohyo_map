import 'package:flutter_test/flutter_test.dart';
import 'package:nihon_future_map/application/usecases/load_policy_simulation.dart';

void main() {
  group('LoadPolicySimulation', () {
    test('5つの指標（人口・年金積立金・国債残高・医療費・空き家率）を返す', () {
      final simulations = LoadPolicySimulation.call();

      expect(simulations.length, 5);
      expect(simulations.map((s) => s.id), [
        'population',
        'pension_reserve',
        'national_debt',
        'healthcare_cost',
        'housing_vacancy',
      ]);
    });

    test('医療費・空き家率は lowerIsBetter が true', () {
      final simulations = LoadPolicySimulation.call();

      final healthcare = simulations.firstWhere(
        (s) => s.id == 'healthcare_cost',
      );
      final housing = simulations.firstWhere((s) => s.id == 'housing_vacancy');

      expect(healthcare.lowerIsBetter, true);
      expect(housing.lowerIsBetter, true);
    });

    test('医療費・空き家率: 現状維持は年々悪化し、専門家案は改善する', () {
      final simulations = LoadPolicySimulation.call();

      final healthcare = simulations.firstWhere(
        (s) => s.id == 'healthcare_cost',
      );
      final housing = simulations.firstWhere((s) => s.id == 'housing_vacancy');

      for (final sim in [healthcare, housing]) {
        final y2070 = sim.dataForYear(2070);
        expect(y2070.baseline, greaterThan(sim.dataForYear(2026).baseline));
        expect(y2070.expert, lessThan(y2070.baseline));
      }
    });

    test('各指標は2026年から2070年まで年ごとのデータを持つ', () {
      final simulations = LoadPolicySimulation.call();

      for (final simulation in simulations) {
        expect(simulation.minYear, 2026);
        expect(simulation.maxYear, 2070);
        expect(simulation.yearData.length, 45);
      }
    });

    test('人口: チェックポイントの年は指定した値と一致する', () {
      final population = LoadPolicySimulation.call().first;

      final y2026 = population.dataForYear(2026);
      expect(y2026.baseline, 124.5);

      final y2070 = population.dataForYear(2070);
      expect(y2070.baseline, 104.4);
      expect(y2070.policyA, 112.0);
      expect(y2070.policyB, 108.0);
      expect(y2070.expert, 116.0);
    });

    test('国債残高は lowerIsBetter が true、他はfalse', () {
      final simulations = LoadPolicySimulation.call();

      final debt = simulations.firstWhere((s) => s.id == 'national_debt');
      final population = simulations.firstWhere((s) => s.id == 'population');
      final pension = simulations.firstWhere((s) => s.id == 'pension_reserve');

      expect(debt.lowerIsBetter, true);
      expect(population.lowerIsBetter, false);
      expect(pension.lowerIsBetter, false);
    });

    test('国債残高: 現状維持は年々悪化し、専門家案は改善する', () {
      final debt = LoadPolicySimulation.call().firstWhere(
        (s) => s.id == 'national_debt',
      );

      final y2070 = debt.dataForYear(2070);
      expect(y2070.baseline, greaterThan(debt.dataForYear(2026).baseline));
      expect(y2070.expert, lessThan(y2070.baseline));
    });

    test('チェックポイント間は線形補間される', () {
      final population = LoadPolicySimulation.call().first;

      final y2033 = population.dataForYear(2033);
      expect(y2033.baseline, greaterThan(119.7));
      expect(y2033.baseline, lessThan(124.5));
    });

    test('範囲外の年は最も近い境界値にクランプされる', () {
      final population = LoadPolicySimulation.call().first;

      final tooEarly = population.dataForYear(2000);
      expect(tooEarly.baseline, population.dataForYear(2026).baseline);

      final tooLate = population.dataForYear(2100);
      expect(tooLate.baseline, population.dataForYear(2070).baseline);
    });
  });
}
