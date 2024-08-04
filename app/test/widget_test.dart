import 'package:flutter_test/flutter_test.dart';
import 'package:mls_app/main.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await tester.pumpWidget(const MlsApp());
    await tester.pump();
    expect(find.text('Music Lesson Studio'), findsOneWidget);
    expect(find.text('Continue to login'), findsOneWidget);
  });
}
