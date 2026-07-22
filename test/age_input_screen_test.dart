import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihon_future_map/presentation/screens/age_input_screen.dart';

void main() {
  Widget buildApp() {
    return const ProviderScope(child: MaterialApp(home: AgeInputScreen()));
  }

  group('AgeInputScreen', () {
    testWidgets('初期状態では質問と入力欄が表示される', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('あなたの年金は\n得？損？'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('結果を見る'), findsOneWidget);
    });

    testWidgets('年齢を入力して結果を見るボタンを押すと損益結果が表示される', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(find.byType(TextField), '30');
      await tester.tap(find.text('結果を見る'));
      await tester.pumpAndSettle();

      expect(find.text('30歳のあなたの結果'), findsOneWidget);
      expect(find.text('結果を画像でシェア'), findsOneWidget);
      expect(find.text('別の年齢で試す'), findsOneWidget);
    });

    testWidgets('範囲外の年齢を入力するとエラーメッセージが表示される', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(find.byType(TextField), '150');
      await tester.tap(find.text('結果を見る'));
      await tester.pump();

      expect(find.text('20〜80の数字で入力してください'), findsOneWidget);
    });

    testWidgets('別の年齢で試すボタンを押すと入力画面に戻る', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(find.byType(TextField), '40');
      await tester.tap(find.text('結果を見る'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('別の年齢で試す'));
      await tester.tap(find.text('別の年齢で試す'));
      await tester.pumpAndSettle();

      expect(find.text('あなたの年金は\n得？損？'), findsOneWidget);
    });
  });
}
