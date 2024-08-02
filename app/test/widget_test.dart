import 'package:flutter_test/flutter_test.dart';
import 'package:mls_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MlsApp());
    expect(find.text('Music Lesson Studio'), findsOneWidget);
    expect(find.text('Continue to login'), findsOneWidget);
  });
}
