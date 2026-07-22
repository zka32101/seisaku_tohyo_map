import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihon_future_map/main.dart';

void main() {
  testWidgets('アプリ起動時にダッシュボード画面が表示される', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();

    expect(find.text('日本の未来'), findsOneWidget);
    expect(find.text('人口はどれだけ減る？'), findsOneWidget);
  });
}
