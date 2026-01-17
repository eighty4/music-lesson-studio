import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mls_studio/editor_interaction.dart';
import 'package:mls_studio/frame_data.dart';
import 'package:mls_studio/frame_menu.dart';

enum TestMenuOption { play, prank, peruse, pursue }

FrameData frameData = FrameData(onFrameDataChange: (_) {});

rebuild(
  WidgetTester tester, {
  List<TestMenuOption>? disabled,
  FrameMenuOptionCallback<TestMenuOption>? callback,
}) async {
  await tester.pumpWidget(
    InheritedFrameData(
      frameData: frameData,
      child: MaterialApp(
        home: Scaffold(
          body: FrameMenu<TestMenuOption>(
            callback: callback ?? (_) {},
            disabled: disabled ?? [],
            options: [
              TestMenuOption.play,
              TestMenuOption.prank,
              TestMenuOption.peruse,
              TestMenuOption.pursue,
            ].map((v) => FrameMenuOption(v.name, v)).toList(),
            predicate: (editorInteraction) =>
                editorInteraction.openCanvasMenu != null,
            child: GestureDetector(child: Container(color: Colors.blue)),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('FrameMenu opens on editor interaction match', (tester) async {
    await tester.binding.setSurfaceSize(const Size(200, 200));
    await rebuild(tester);
    EditorData.openCanvasMenu();
    await tester.pump();
    expect(find.byType(FrameMenuOptionListItem).evaluate().length, equals(4));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('gold/frame_menu/open.png'),
      skip: !Platform.isMacOS,
    );
  });
  testWidgets('FrameMenu fires callback on click', (tester) async {
    await tester.binding.setSurfaceSize(const Size(200, 200));
    TestMenuOption? clicked;
    await rebuild(tester, callback: (option) => clicked = option);
    EditorData.openCanvasMenu();
    await tester.pump();
    await tester.tap(find.byType(FrameMenuOptionListItem).at(1));
    expect(clicked, equals(TestMenuOption.prank));
  });
  testWidgets('FrameMenu disabled options are non interactive', (tester) async {
    await tester.binding.setSurfaceSize(const Size(200, 200));
    TestMenuOption? clicked;
    await rebuild(
      tester,
      callback: (option) => clicked = option,
      disabled: [TestMenuOption.play],
    );
    EditorData.openCanvasMenu();
    await tester.pump();
    expect(find.byType(FrameMenuOptionListItem).evaluate().length, equals(4));
    await tester.tap(find.byType(FrameMenuOptionListItem).first);
    expect(clicked, equals(null));
  });
}
