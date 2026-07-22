import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihon_future_map/presentation/screens/quiz_screen.dart';

void main() {
  Widget buildApp() {
    return const ProviderScope(child: MaterialApp(home: QuizScreen()));
  }

  group('QuizScreen', () {
    testWidgets('最初の問題と入力欄が表示される', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.text('ギャップクイズ 1/15'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('答え合わせ'), findsOneWidget);
    });

    testWidgets('予想を入力して答え合わせすると結果カードが表示される', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '1000');
      await tester.tap(find.text('答え合わせ'));
      await tester.pump();

      expect(find.text('あなたの予想'), findsOneWidget);
      expect(find.text('実際の値'), findsOneWidget);
      expect(find.text('次の問題へ'), findsOneWidget);
    });

    testWidgets('数字以外を入力するとエラーメッセージが表示される', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text('答え合わせ'));
      await tester.pump();

      expect(find.text('数字で入力してください'), findsOneWidget);
    });

    testWidgets('次の問題へ進むと設問番号が更新される', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '1000');
      await tester.tap(find.text('答え合わせ'));
      await tester.pump();

      await tester.tap(find.text('次の問題へ'));
      await tester.pump();

      expect(find.text('ギャップクイズ 2/15'), findsOneWidget);
    });
  });
}
