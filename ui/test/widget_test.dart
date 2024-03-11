import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mls_ui/main.dart';

void main() {
  testWidgets('This is extreme adherence to super duper important TDD process',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudioEditorApp());
    await tester.tap(find.byIcon(Icons.music_note));
  });
}
