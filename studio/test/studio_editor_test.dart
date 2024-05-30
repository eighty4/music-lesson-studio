import 'package:flutter_test/flutter_test.dart';
import 'package:mls_studio/editor_session.dart';
import 'package:mls_studio/get_started.dart';
import 'package:mls_studio/studio_editor.dart';

void main() {
  testWidgets('This is extreme adherence to super duper important TDD process',
      (WidgetTester tester) async {
    await tester.pumpWidget(StudioEditorApp(
        provideSessionParams: () => EditorSession(apiHost: '')));
    expect(find.text('Loading data'), findsOneWidget);
    await tester.pump();
    expect(find.byType(GetStartedLanding), findsOneWidget);
  });
}
