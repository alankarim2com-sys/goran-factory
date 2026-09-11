import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goran/main.dart';

void main() {
  testWidgets('workforce app opens the Kurdish dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const WorkforceApp());
    await tester.pumpAndSettle();

    expect(find.text('بەڕێوەبردنی کرێکاران'), findsOneWidget);
    expect(find.text('سڵاو، بەخێربێیت'), findsOneWidget);
    expect(find.text('کۆی کرێکاران'), findsOneWidget);
  });
}
