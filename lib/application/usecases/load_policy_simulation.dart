import '../../domain/entities/policy_scenario.dart';

class LoadPolicySimulation {
  static const _checkpointYears = [2026, 2040, 2055, 2070];

  static List<PolicySimulation> call() {
    return [
      _build(
        id: 'population',
        title: '人口推移シミュレーション',
        unit: '百万人',
        checkpoints: {
          2026: {
            'baseline': 124.5,
            'policyA': 124.5,
            'policyB': 124.5,
            'expert': 124.5,
          },
          2040: {
            'baseline': 119.7,
            'policyA': 121.0,
            'policyB': 120.3,
            'expert': 122.0,
          },
          2055: {
            'baseline': 111.5,
            'policyA': 116.0,
            'policyB': 113.5,
            'expert': 118.5,
          },
          2070: {
            'baseline': 104.4,
            'policyA': 112.0,
            'policyB': 108.0,
            'expert': 116.0,
          },
        },
      ),
      _build(
        id: 'pension_reserve',
        title: '年金積立金シミュレーション',
        unit: '兆円',
        checkpoints: {
          2026: {
            'baseline': 245.0,
            'policyA': 245.0,
            'policyB': 245.0,
            'expert': 245.0,
          },
          2040: {
            'baseline': 220.0,
            'policyA': 228.0,
            'policyB': 225.0,
            'expert': 232.0,
          },
          2055: {
            'baseline': 180.0,
            'policyA': 195.0,
            'policyB': 185.0,
            'expert': 205.0,
          },
          2070: {
            'baseline': 150.0,
            'policyA': 175.0,
            'policyB': 160.0,
            'expert': 190.0,
          },
        },
      ),
      _build(
        id: 'national_debt',
        title: '国債残高シミュレーション',
        unit: '%（対GDP）',
        lowerIsBetter: true,
        checkpoints: {
          2026: {
            'baseline': 266.0,
            'policyA': 266.0,
            'policyB': 266.0,
            'expert': 266.0,
          },
          2040: {
            'baseline': 290.0,
            'policyA': 275.0,
            'policyB': 260.0,
            'expert': 250.0,
          },
          2055: {
            'baseline': 310.0,
            'policyA': 270.0,
            'policyB': 235.0,
            'expert': 210.0,
          },
          2070: {
            'baseline': 330.0,
            'policyA': 255.0,
            'policyB': 200.0,
            'expert': 170.0,
          },
        },
      ),
      _build(
        id: 'healthcare_cost',
        title: '医療費シミュレーション',
        unit: '兆円',
        lowerIsBetter: true,
        checkpoints: {
          2026: {
            'baseline': 48.0,
            'policyA': 48.0,
            'policyB': 48.0,
            'expert': 48.0,
          },
          2040: {
            'baseline': 58.0,
            'policyA': 54.0,
            'policyB': 50.0,
            'expert': 47.0,
          },
          2055: {
            'baseline': 65.0,
            'policyA': 56.0,
            'policyB': 48.0,
            'expert': 42.0,
          },
          2070: {
            'baseline': 68.0,
            'policyA': 55.0,
            'policyB': 45.0,
            'expert': 38.0,
          },
        },
      ),
      _build(
        id: 'housing_vacancy',
        title: '空き家率シミュレーション',
        unit: '%',
        lowerIsBetter: true,
        checkpoints: {
          2026: {
            'baseline': 14.0,
            'policyA': 14.0,
            'policyB': 14.0,
            'expert': 14.0,
          },
          2040: {
            'baseline': 17.0,
            'policyA': 15.5,
            'policyB': 14.5,
            'expert': 13.5,
          },
          2055: {
            'baseline': 19.5,
            'policyA': 16.0,
            'policyB': 14.0,
            'expert': 11.5,
          },
          2070: {
            'baseline': 21.0,
            'policyA': 16.5,
            'policyB': 13.5,
            'expert': 10.0,
          },
        },
      ),
    ];
  }

  static PolicySimulation _build({
    required String id,
    required String title,
    required String unit,
    required Map<int, Map<String, double>> checkpoints,
    bool lowerIsBetter = false,
  }) {
    final yearData = <PolicyYearData>[];

    for (
      int year = _checkpointYears.first;
      year <= _checkpointYears.last;
      year++
    ) {
      yearData.add(
        PolicyYearData(
          year: year,
          baseline: _interpolate(year, checkpoints, 'baseline'),
          policyA: _interpolate(year, checkpoints, 'policyA'),
          policyB: _interpolate(year, checkpoints, 'policyB'),
          expert: _interpolate(year, checkpoints, 'expert'),
        ),
      );
    }

    return PolicySimulation(
      id: id,
      title: title,
      unit: unit,
      lowerIsBetter: lowerIsBetter,
      yearData: yearData,
    );
  }

  static double _interpolate(
    int year,
    Map<int, Map<String, double>> checkpoints,
    String key,
  ) {
    if (year <= _checkpointYears.first) {
      return checkpoints[_checkpointYears.first]![key]!;
    }
    if (year >= _checkpointYears.last) {
      return checkpoints[_checkpointYears.last]![key]!;
    }

    for (int i = 0; i < _checkpointYears.length - 1; i++) {
      final y0 = _checkpointYears[i];
      final y1 = _checkpointYears[i + 1];
      if (year >= y0 && year <= y1) {
        final v0 = checkpoints[y0]![key]!;
        final v1 = checkpoints[y1]![key]!;
        final ratio = (year - y0) / (y1 - y0);
        return v0 + (v1 - v0) * ratio;
      }
    }
    return checkpoints[_checkpointYears.last]![key]!;
  }
}
