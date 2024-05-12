import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mls_studio/api_types.dart';
import 'package:mls_studio/entity_edge.dart';
import 'package:mls_studio/frame_scaling.dart';
import 'package:mls_studio/frame_widget.dart';

import 'frame_widget_test.dart';

class ResizeTest {
  final String description;
  final Offset distance;
  final Entity entity;
  final Offset expectOffset;
  final Size expectSize;
  final Offset start;
  final Size testSize;

  ResizeTest(
      {required this.description,
      required this.distance,
      required this.entity,
      required this.expectOffset,
      required this.expectSize,
      required this.start,
      required this.testSize});

  Offset startOffset(FrameScaling frameScaling) {
    final projection = frameScaling.projectEntity(entity);
    final startOffset = projection.offset +
        Offset(
          start.dx > 0 ? start.dx : projection.size.width + start.dx,
          start.dy > 0 ? start.dy : projection.size.width + start.dy,
        );
    return startOffset;
  }
}

final resizeTests = {
  EntityEdge.topLeft: [
    ResizeTest(
        description: 'bigger on top left edge',
        distance: const Offset(-10, -10),
        entity: Entity(
          offset: const Offset(.2, .2),
          size: const Size(.4, .4),
          type: EntityType.chordChart,
        ),
        expectOffset: const Offset(.1, .1),
        expectSize: const Size(.5, .5),
        start: const Offset(2, 2),
        testSize: const Size(100, 100)),
    ResizeTest(
        description: 'smaller on top left edge',
        distance: const Offset(10, 10),
        entity: Entity(
          offset: const Offset(.2, .2),
          size: const Size(.4, .4),
          type: EntityType.chordChart,
        ),
        expectOffset: const Offset(.3, .3),
        expectSize: const Size(.3, .3),
        start: const Offset(2, 2),
        testSize: const Size(100, 100)),
    ResizeTest(
        description: 'narrower on right edge',
        distance: const Offset(-20, 0),
        entity: Entity(
          offset: const Offset(.2, .2),
          size: const Size(.4, .4),
          type: EntityType.chordChart,
        ),
        expectOffset: const Offset(.2, .2),
        expectSize: const Size(.2, .4),
        start: const Offset(-2, 20),
        testSize: const Size(100, 100)),
    ResizeTest(
        description: 'taller on bottom edge',
        distance: const Offset(0, 10),
        entity: Entity(
          offset: const Offset(.2, .2),
          size: const Size(.4, .4),
          type: EntityType.chordChart,
        ),
        expectOffset: const Offset(.2, .2),
        expectSize: const Size(.4, .5),
        start: const Offset(20, -2),
        testSize: const Size(100, 100)),
  ],
};

void main() {
  for (final entityEdge in resizeTests.keys) {
    for (final resize in resizeTests[entityEdge]!) {
      testEditorPane('Resize entity ${resize.description}',
          goldPath:
              'gold/frame_widget/resize_${resize.description.toLowerCase().replaceAll(' ', '_')}.png',
          testSize: resize.testSize,
          test: (frameData, frameScaling, rebuild, states, tester) async {
        frameData.addEntity(resize.entity);
        await rebuild();

        final resizeStartOffset = resize.startOffset(frameScaling);

        var pointers = 0;
        final pointer = TestPointer(pointers++, PointerDeviceKind.mouse);
        tester.binding.handlePointerEvent(
            pointer.hover(Offset(resizeStartOffset.dx, resizeStartOffset.dy)));
        final gesture = await tester.createGesture(
            pointer: pointers++, kind: PointerDeviceKind.mouse);
        await gesture.down(Offset(resizeStartOffset.dx, resizeStartOffset.dy));
        // first moveBy with arbitrary offset required to trigger a pan start
        final centerOffset = tester.getCenter(find.byType(FrameEntityWidget));
        await gesture.moveBy(Offset(
          centerOffset.dx > resizeStartOffset.dx ? 3 : -3,
          centerOffset.dy > resizeStartOffset.dy ? 3 : -3,
        ));
        // for this to be a pan update
        await gesture.moveBy(resize.distance);
        await gesture.up();

        expect(states.length, equals(2));
        expect(states[1], equals(frameData.state));
        expect(frameData.state.frames.length, equals(1));
        expectEntity(
          frameData.state.frames[0].entities[0],
          resize.entity,
          expectedOffset: resize.expectOffset,
          expectedSize: resize.expectSize,
        );
      });
    }
  }
}
