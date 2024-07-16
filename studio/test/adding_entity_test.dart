import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_api/api_types.dart';
import 'package:mls_studio/adding_entity.dart';
import 'package:mls_studio/editor_interaction.dart';
import 'package:mls_studio/frame_data.dart';
import 'package:mls_studio/frame_scaling.dart';
import 'package:mls_studio/frame_widget.dart';

final tabContext = TabContext.forBrightness(Brightness.dark);

Widget createAddingEntity(FrameData frameData, FrameScaling frameScaling) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
        body: InheritedFrameData(
      frameData: frameData,
      child: AddingEntity(
        frameScaling: frameScaling,
        tabContext: tabContext,
      ),
    )),
  );
}

main() {
  testWidgets('AddingEntity greater than min size', (tester) async {
    const testSize = Size(200, 150);
    await tester.binding.setSurfaceSize(testSize);
    final List<FrameDataState> states = [];
    final frameScaling =
        FrameScaling(frameOffset: Offset.zero, frameSize: testSize);
    final frameData = FrameData(onFrameDataChange: states.add);
    await tester.pumpWidget(createAddingEntity(frameData, frameScaling));

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
        matchesGoldenFile('gold/adding_entity/gt_min_size.png'),
        skip: !Platform.isMacOS);

    await gesture.up();
    await tester.pump();
    expect(find.byType(FrameEntityWidget), findsNothing);

    expect(states.length, equals(1));
    expect(states[0].frames.length, equals(1));
    expect(states[0].frames[0].entities.length, equals(1));
    final result = states[0].frames[0].entities[0];
    expect(result.offset, equals(const Offset(.25, .2)));
    expect(result.size, equals(const Size(.5, .6)));
  });

  testWidgets('AddingEntity min size', (tester) async {
    const testSize = Size(150, 250);
    await tester.binding.setSurfaceSize(testSize);
    final List<FrameDataState> states = [];
    final frameScaling =
        FrameScaling(frameOffset: Offset.zero, frameSize: testSize);
    final frameData = FrameData(onFrameDataChange: states.add);
    await tester.pumpWidget(createAddingEntity(frameData, frameScaling));

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
        matchesGoldenFile('gold/adding_entity/eq_min_size.png'),
        skip: !Platform.isMacOS);

    await gesture.up();
    await tester.pump();
    expect(find.byType(FrameEntityWidget), findsNothing);

    expect(states.length, equals(1));
    expect(states[0].frames.length, equals(1));
    expect(states[0].frames[0].entities.length, equals(1));
    final result = states[0].frames[0].entities[0];
    expect(result.offset, equals(const Offset(.1, .1)));
    expect(result.size, equals(EntityType.chordChart.defaultSize() / 5));
  });

  testWidgets('AddingEntity with origin set by pan start instead of tap down',
      (tester) async {
    const testSize = Size(150, 250);
    await tester.binding.setSurfaceSize(testSize);
    final List<FrameDataState> states = [];
    final frameScaling =
        FrameScaling(frameOffset: Offset.zero, frameSize: testSize);
    final frameData = FrameData(onFrameDataChange: states.add);
    await tester.pumpWidget(createAddingEntity(frameData, frameScaling));

    EditorData.startAddEntityInteraction(EntityType.chordChart);
    await tester.pump();

    const addOffset = Offset(15, 25);
    var pointers = 0;
    final gesture = await tester.createGesture(
        pointer: pointers++, kind: PointerDeviceKind.mouse);
    await gesture.moveTo(addOffset);
    await gesture.down(addOffset);
    await tester.pump();
    expect(find.byType(FrameEntityWidget), findsOneWidget);

    await gesture.moveTo(addOffset + const Offset(2, 2));
    await gesture.moveTo(addOffset + const Offset(4, 4));
    await tester.pump();
    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('gold/adding_entity/pan_start_offset.png'),
        skip: !Platform.isMacOS);

    await gesture.up();
    await tester.pump();
    expect(find.byType(FrameEntityWidget), findsNothing);

    expect(states.length, equals(1));
    expect(states[0].frames.length, equals(1));
    expect(states[0].frames[0].entities.length, equals(1));
    final result = states[0].frames[0].entities[0];
    expect(result.offset, isNot(equals(Offset.zero)));
  });

  testWidgets('AddingEntity interaction cancelled with escape key',
      (tester) async {
    const testSize = Size(700, 500);
    await tester.binding.setSurfaceSize(testSize);
    final List<FrameDataState> states = [];
    final frameScaling =
        FrameScaling(frameOffset: Offset.zero, frameSize: testSize);
    final frameData = FrameData(onFrameDataChange: states.add);
    await tester.pumpWidget(createAddingEntity(frameData, frameScaling));

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
