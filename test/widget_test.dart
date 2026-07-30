import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihon_future_map/main.dart';

void main() {
  testWidgets('初回起動時はコンテンツポリシー同意画面が表示される', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();

    expect(find.text('ご利用の前に'), findsOneWidget);
    expect(find.text('同意して始める'), findsOneWidget);
  });

  testWidgets('同意するとダッシュボード画面が表示される', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();

    await tester.tap(find.text('同意して始める'));
    await tester.pump();
    await tester.pump();

    expect(find.text('日本の未来'), findsOneWidget);
    expect(find.text('人口はどれだけ減る？'), findsOneWidget);
  });
}
