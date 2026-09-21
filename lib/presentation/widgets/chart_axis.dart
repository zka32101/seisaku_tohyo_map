import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 折れ線グラフをタップした際に「年 + 単位付きの数値」を明示するツールチップ。
/// グリッド線と軸目盛りだけでは読み取りにくい正確な値を、タップ操作で
/// 確実に確認できるようにする（グラフ全画面共通のスタイル）。
LineTouchData buildLineTooltipTouchData({
  required Color color,
  required String Function(int index) labelForIndex,
  required String Function(double y) valueFormatter,
}) {
  return LineTouchData(
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (touchedSpot) => color,
      getTooltipItems: (touchedSpots) {
        return touchedSpots.map((spot) {
          final index = spot.x.round();
          return LineTooltipItem(
            '${labelForIndex(index)}\n${valueFormatter(spot.y)}',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          );
        }).toList();
      },
    ),
  );
}

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
