import 'dart:math';

/// 折れ線グラフのY軸に使う「きりのいい」目盛り間隔を計算する
double niceAxisInterval(double min, double max, {int steps = 4}) {
  final range = (max - min).abs();
  if (range <= 0) return 1;

  final rough = range / steps;
  final magnitude = pow(10, (log(rough) / ln10).floor()).toDouble();
  final residual = rough / magnitude;

  double niceResidual;
  if (residual > 5) {
    niceResidual = 10;
  } else if (residual > 2) {
    niceResidual = 5;
  } else if (residual > 1) {
    niceResidual = 2;
  } else {
    niceResidual = 1;
  }

  final interval = niceResidual * magnitude;
  return interval <= 0 ? 1 : interval;
}
