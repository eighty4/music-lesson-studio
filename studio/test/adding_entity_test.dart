import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_studio/adding_entity.dart';
import 'package:mls_studio/api_types.dart';
import 'package:mls_studio/editor_data.dart';
import 'package:mls_studio/editor_session.dart';
import 'package:mls_studio/frame_data.dart';
import 'package:mls_studio/frame_scaling.dart';
import 'package:mls_studio/frame_widget.dart';
import 'package:mls_studio/studio_editor.dart';

import 'api_types_test.dart';

final tabContext = TabContext.forBrightness(Brightness.dark);

main() {
  testWidgets('AddingEntity greater than min size', (tester) async {
    const testSize = Size(200, 150);
    await tester.binding.setSurfaceSize(testSize);
    final List<FrameDataState> states = [];
    final frameScaling =
        FrameScaling(frameOffset: Offset.zero, frameSize: testSize);
    final frameData =
        FrameData(onFrameDataChange: (state) => states.add(state));
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: InheritedFrameData(
        frameData: frameData,
        child: AddingEntity(
          frameScaling: frameScaling,
          tabContext: tabContext,
        ),
      )),
    ));

    EditorData.startAddEntityInteraction(EntityType.chordChart);
    await tester.pump();

    var pointers = 0;
    final gesture = await tester.createGesture(
        pointer: pointers++, kind: PointerDeviceKind.mouse);
    // GestureDetector.onTapDown must have a pump with duration
    await gesture.moveTo(const Offset(50, 30));
    await gesture.down(const Offset(50, 30));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(FrameEntityWidget), findsOneWidget);

    await gesture.moveTo(const Offset(60, 60));
    await gesture.moveTo(Offset(testSize.width - 50, testSize.height - 30));
    await tester.pump();
    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('gold/adding_entity/gt_min_size.png'));

    await gesture.up();
    await tester.pump();
    expect(find.byType(FrameEntityWidget), findsNothing);

    expect(states.length, equals(1));
    expect(states[0].frames.length, equals(1));
    expect(states[0].frames[0].entities.length, equals(1));
    final result = states[0].frames[0].entities[0];
    expectEntity(
        result,
        result.mutate(
          offset: const Offset(.25, .2),
          size: const Size(.5, .6),
        ));
  });

  testWidgets('AddingEntity min size', (tester) async {
    const testSize = Size(150, 250);
    await tester.binding.setSurfaceSize(testSize);
    final List<FrameDataState> states = [];
    final frameScaling =
        FrameScaling(frameOffset: Offset.zero, frameSize: testSize);
    final frameData =
        FrameData(onFrameDataChange: (state) => states.add(state));
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: InheritedFrameData(
        frameData: frameData,
        child: AddingEntity(
          frameScaling: frameScaling,
          tabContext: tabContext,
        ),
      )),
    ));

    EditorData.startAddEntityInteraction(EntityType.chordChart);
    await tester.pump();

    const addOffset = Offset(15, 25);
    var pointers = 0;
    final gesture = await tester.createGesture(
        pointer: pointers++, kind: PointerDeviceKind.mouse);
    // GestureDetector.onTapDown must have a pump with duration
    await gesture.moveTo(addOffset);
    await gesture.down(addOffset);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(FrameEntityWidget), findsOneWidget);

    await gesture.moveTo(addOffset + const Offset(2, 2));
    await gesture.moveTo(addOffset + const Offset(4, 4));
    await tester.pump();
    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('gold/adding_entity/eq_min_size.png'));

    await gesture.up();
    await tester.pump();
    expect(find.byType(FrameEntityWidget), findsNothing);

    expect(states.length, equals(1));
    expect(states[0].frames.length, equals(1));
    expect(states[0].frames[0].entities.length, equals(1));
    final result = states[0].frames[0].entities[0];
    expectEntity(
        result,
        result.mutate(
          offset: const Offset(.1, .1),
          size: EntityType.chordChart.defaultSize() / 5,
        ));
  });

  testWidgets('AddingEntity interaction cancelled with escape key',
      (tester) async {
    const testSize = Size(700, 500);
    await tester.binding.setSurfaceSize(testSize);
    await tester.pumpWidget(StudioEditorApp(
        initEditorSession: () => const EditorSession(apiHost: '')));

    EditorData.startAddEntityInteraction(EntityType.chordChart);
    await tester.pump();

    const addOffset = Offset(200, 200);
    var pointers = 0;
    final gesture = await tester.createGesture(
        pointer: pointers++, kind: PointerDeviceKind.mouse);
    // GestureDetector.onTapDown must have a pump with duration
    await gesture.moveTo(addOffset);
    await gesture.down(addOffset);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(FrameEntityWidget), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byType(FrameEntityWidget), findsNothing);
  });
}
