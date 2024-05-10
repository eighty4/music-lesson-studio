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

void main() {
  testWidgets('Select frame entity widget', (WidgetTester tester) async {
    const testSize = Size(100, 100);
    await tester.binding.setSurfaceSize(testSize);
    final entity = Entity(
      offset: const Offset(.2, .2),
      size: const Size(.4, .4),
      type: EntityType.chordChart,
    );
    final frameData = FrameData();
    final frameScaling =
        FrameScaling(frameOffset: Offset.zero, frameSize: testSize);
    final tabContext = TabContext.forBrightness(Brightness.dark);

    await tester.pumpWidget(InheritedFrameData(
      frameData: frameData,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: EditorPane(
          frameDataStream: frameData.stream,
          frameScaling: frameScaling,
          globalCursorPosition: Offset.zero,
          tabContext: tabContext,
        ),
      ),
    ));
    frameData.addEntity(entity);
    await tester.pumpAndSettle();

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.down(Offset(
        frameScaling.frameOffset.dx + 22, frameScaling.frameOffset.dy + 22));
    await gesture.up();
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(FrameEntityWidget),
      matchesGoldenFile('gold/frame_widget/select_entity.png'),
    );
  });

  testWidgets('Move frame entity widget', (WidgetTester tester) async {
    const testSize = Size(100, 100);
    await tester.binding.setSurfaceSize(testSize);
    final entity = Entity(
      offset: const Offset(.2, .2),
      size: const Size(.4, .4),
      type: EntityType.chordChart,
    );
    final frameData = FrameData();
    final frameScaling =
        FrameScaling(frameOffset: Offset.zero, frameSize: testSize);
    final tabContext = TabContext.forBrightness(Brightness.dark);

    await tester.pumpWidget(InheritedFrameData(
      frameData: frameData,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: EditorPane(
          frameDataStream: frameData.stream,
          frameScaling: frameScaling,
          globalCursorPosition: Offset.zero,
          tabContext: tabContext,
        ),
      ),
    ));
    frameData.addEntity(entity);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(FrameEntityWidget), const Offset(40, 40),
        kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(FrameEntityWidget),
      matchesGoldenFile('gold/frame_widget/move_entity.png'),
    );

    expect(frameData.state.frames[0].entities[0].offset,
        equals(const Offset(.4, .4)));
  });

  testWidgets('Move frame entity widget to canvas edge clamps move offset',
      (WidgetTester tester) async {
    const testSize = Size(100, 100);
    await tester.binding.setSurfaceSize(testSize);
    final entity = Entity(
      offset: const Offset(.2, .2),
      size: const Size(.4, .4),
      type: EntityType.chordChart,
    );
    final frameData = FrameData();
    final frameScaling =
        FrameScaling(frameOffset: Offset.zero, frameSize: testSize);
    final tabContext = TabContext.forBrightness(Brightness.dark);

    await tester.pumpWidget(InheritedFrameData(
      frameData: frameData,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: EditorPane(
          frameDataStream: frameData.stream,
          frameScaling: frameScaling,
          globalCursorPosition: Offset.zero,
          tabContext: tabContext,
        ),
      ),
    ));
    frameData.addEntity(entity);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(FrameEntityWidget), const Offset(100, 100),
        kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(FrameEntityWidget),
      matchesGoldenFile('gold/frame_widget/move_entity_to_edge.png'),
    );

    expect(frameData.state.frames[0].entities[0].offset,
        equals(const Offset(.6, .6)));
  });
}
