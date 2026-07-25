// App Store提出用のスクリーンショットを、実機・シミュレータなしで生成するテスト。
// 通常の `flutter test` では実行されないよう `screenshot` タグを付与し、
// CI側では `flutter test --tags=screenshot` として専用ジョブでのみ実行する。
@Tags(['screenshot'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihon_future_map/infrastructure/firebase/firebase_service.dart';
import 'package:nihon_future_map/presentation/screens/challenge_detail_screen.dart';
import 'package:nihon_future_map/presentation/screens/macro_dashboard_screen.dart';
import 'package:nihon_future_map/presentation/screens/overview_map_screen.dart';
import 'package:nihon_future_map/presentation/screens/quiz_screen.dart';
import 'package:nihon_future_map/presentation/screens/ranking_screen.dart';
import 'package:nihon_future_map/presentation/theme/app_theme.dart';

// App Store Connect が要求する「6.5インチのiPhoneディスプレイ」の物理解像度。
// devicePixelRatio 3.0・論理サイズ 414x896（iPhone 11 Pro Max/XS Max相当）。
const _physicalSize = Size(1242, 2688);
const _devicePixelRatio = 3.0;

void main() {
  Future<void> capture(WidgetTester tester, String name, Widget screen) async {
    tester.view.physicalSize = _physicalSize;
    tester.view.devicePixelRatio = _devicePixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          title: '日本の未来マップ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: RepaintBoundary(key: boundaryKey, child: screen),
        ),
      ),
    );
    // 非同期provider（モックデータ読み込み等）の解決を待つ
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    await tester.runAsync(() async {
      final boundary =
          boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: _devicePixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/screenshots/$name.png');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(byteData!.buffer.asUint8List());
    });
  }

  testWidgets('01_dashboard', (tester) async {
    await capture(tester, '01_dashboard', const MacroDashboardScreen());
  });

  testWidgets('02_overview_map', (tester) async {
    await capture(tester, '02_overview_map', const OverviewMapScreen());
  });

  testWidgets('03_challenge_detail', (tester) async {
    final challenges = FirebaseService.getMockChallenges();
    final challenge = challenges.firstWhere(
      (c) => c.id == 'finance_ministry_narrative_control',
      orElse: () => challenges.first,
    );
    await capture(
      tester,
      '03_challenge_detail',
      ChallengeDetailScreen(challenge: challenge),
    );
  });

  testWidgets('04_ranking_map', (tester) async {
    tester.view.physicalSize = _physicalSize;
    tester.view.devicePixelRatio = _devicePixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          title: '日本の未来マップ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: RepaintBoundary(key: boundaryKey, child: const RankingScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // 「マップ」タブに切り替えてからキャプチャする
    await tester.tap(find.text('マップ'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    await tester.runAsync(() async {
      final boundary =
          boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: _devicePixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/screenshots/04_ranking_map.png');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(byteData!.buffer.asUint8List());
    });
  });

  testWidgets('05_quiz', (tester) async {
    await capture(tester, '05_quiz', const QuizScreen());
  });
}
