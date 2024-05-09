import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mls_studio/editor_session.dart';
import 'package:mls_studio/studio_editor.dart';

void main() {
  testWidgets('This is extreme adherence to super duper important TDD process',
      (WidgetTester tester) async {
    await tester.pumpWidget(StudioEditorApp(
        initEditorSession: () => const EditorSession(apiHost: '')));
    expect(find.byIcon(Icons.music_note), findsNWidgets(2));
  });
}
