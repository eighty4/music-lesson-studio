import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libtab/context.dart';
import 'package:mls_studio/api_types.dart';
import 'package:mls_studio/editor_pane.dart';
import 'package:mls_studio/frame_data.dart';
import 'package:mls_studio/frame_scaling.dart';
import 'package:mls_studio/frame_widget.dart';

Future<void> buildEditorPane(WidgetTester tester,
    {required FrameData frameData, required Size testSize}) async {
  await tester.pumpWidget(InheritedFrameData(
    frameData: frameData,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: EditorPane(
        currentFrame: frameData.state.currentFrame,
        frameScaling:
            FrameScaling(frameOffset: Offset.zero, frameSize: testSize),
        globalCursorPosition: Offset.zero,
        tabContext: TabContext.forBrightness(Brightness.dark),
      ),
    ),
  ));
}

void expectEntity(Entity actual, Entity expected,
    {Offset? expectedOffset, Size? expectedSize}) {
  expect(actual.key, equals(expected.key));
  expect(actual.type, equals(expected.type));
  expect(actual.offset, equals(expectedOffset ?? expected.offset));
  expect(actual.size, equals(expectedSize ?? expected.size));
}

void main() {
  testWidgets('Select frame entity widget', (WidgetTester tester) async {
    const testSize = Size(100, 100);
    await tester.binding.setSurfaceSize(testSize);
    final entity = Entity(
      offset: const Offset(.2, .2),
      size: const Size(.4, .4),
      type: EntityType.chordChart,
    );

    List<FrameDataState> states = [];
    final frameData =
        FrameData(onFrameDataChange: (state) => states.add(state));

    frameData.addEntity(entity);
    await buildEditorPane(tester, frameData: frameData, testSize: testSize);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.down(const Offset(22, 22));
    await gesture.up();
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(FrameEntityWidget),
      matchesGoldenFile('gold/frame_widget/select_entity.png'),
    );

    expect(states.length, equals(1));
    expect(states[0], equals(frameData.state));
    expectEntity(frameData.state.currentFrame.entities[0], entity);
  });

  testWidgets('Move frame entity widget', (WidgetTester tester) async {
    const testSize = Size(100, 100);
    await tester.binding.setSurfaceSize(testSize);
    final entity = Entity(
      offset: const Offset(.2, .2),
      size: const Size(.4, .4),
      type: EntityType.chordChart,
    );

    List<FrameDataState> states = [];
    final frameData =
        FrameData(onFrameDataChange: (state) => states.add(state));

    frameData.addEntity(entity);
    await buildEditorPane(tester, frameData: frameData, testSize: testSize);

    await tester.drag(find.byType(FrameEntityWidget), const Offset(40, 40),
        kind: PointerDeviceKind.mouse);
    await buildEditorPane(tester, frameData: frameData, testSize: testSize);

    await expectLater(
      find.byType(FrameEntityWidget),
      matchesGoldenFile('gold/frame_widget/move_entity.png'),
    );

    expect(states.length, equals(2));
    expect(states[1], equals(frameData.state));
    expectEntity(frameData.state.currentFrame.entities[0], entity,
        expectedOffset: const Offset(.4, .4));
  });

  testWidgets('Clamp move frame entity widget to canvas edge',
      (WidgetTester tester) async {
    const testSize = Size(100, 100);
    await tester.binding.setSurfaceSize(testSize);
    final entity = Entity(
      offset: const Offset(.2, .2),
      size: const Size(.4, .4),
      type: EntityType.chordChart,
    );

    List<FrameDataState> states = [];
    final frameData =
        FrameData(onFrameDataChange: (state) => states.add(state));

    frameData.addEntity(entity);
    await buildEditorPane(tester, frameData: frameData, testSize: testSize);

    await tester.drag(find.byType(FrameEntityWidget), const Offset(100, 100),
        kind: PointerDeviceKind.mouse);
    await buildEditorPane(tester, frameData: frameData, testSize: testSize);

    await expectLater(
      find.byType(FrameEntityWidget),
      matchesGoldenFile('gold/frame_widget/move_entity_clamp.png'),
    );

    expect(states.length, equals(2));
    expect(states[1], equals(frameData.state));
    expectEntity(frameData.state.currentFrame.entities[0], entity,
        expectedOffset: const Offset(.6, .6));
  });
}
