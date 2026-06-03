import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zyfun_mobile/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('应用可以正常构建', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ZyfunApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(ZyfunApp), findsOneWidget);
  });
}
