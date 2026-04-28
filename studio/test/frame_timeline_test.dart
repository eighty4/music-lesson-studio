import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libtab/context.dart';
import 'package:mls_studio/frame_data.dart';
import 'package:mls_studio/frame_menu.dart';
import 'package:mls_studio/frame_timeline.dart';

final tabContext = TabContext.forBrightness(Brightness.dark);

Future<void> rebuild(WidgetTester tester, FrameData frameData) async {
  await tester.pumpWidget(
    InheritedFrameData(
      frameData: frameData,
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: FrameTimeline(
              currentFrame: frameData.state.currentFrame,
              frames: frameData.state.frames,
              height: 50,
              tabContext: tabContext,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('FrameTimeline adds frame', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 200));
    final frameData = FrameData(onFrameDataChange: (_) {});
    await rebuild(tester, frameData);

    await tester.tap(
      find.byType(AddFrameButton).first,
      buttons: kPrimaryButton,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();

    expect(frameData.state.frames.length, equals(2));
  });
  testWidgets('FrameTimeline unable to add more than max frames', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 200));
    final frameData = FrameData(onFrameDataChange: (_) {});
    await rebuild(tester, frameData);

    while (frameData.state.frames.length < FrameData.maxFrames) {
      await tester.tap(
        find.byType(AddFrameButton).first,
        buttons: kPrimaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
    }

    await rebuild(tester, frameData);
    expect(find.byType(AddFrameButton), findsNothing);
  });
  testWidgets('FrameTimeline reorder first frame to last with drag and drop', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 200));
    final frameData = FrameData(onFrameDataChange: (_) {});
    frameData.addFrame();
    frameData.addFrame();
    frameData.addFrame();
    final reorderingFrameKey = frameData.state.frames.first.key;
    await rebuild(tester, frameData);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Draggable<UniqueKey>).first),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(100, 100));
    await tester.pump();
    expect(
      find.byType(FrameReorderDragTarget).evaluate().length,
      equals(frameData.state.frames.length - 1),
    );

    await gesture.moveTo(
      tester.getCenter(find.byType(FrameReorderDragTarget).last),
    );
    await gesture.up();

    expect(frameData.state.frames.last.key, equals(reorderingFrameKey));
  });
  testWidgets(
    'FrameTimeline reorder first frame to middle with drag and drop',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 200));
      final frameData = FrameData(onFrameDataChange: (_) {});
      frameData.addFrame();
      frameData.addFrame();
      frameData.addFrame();
      frameData.addFrame();
      final reorderingFrameKey = frameData.state.frames.first.key;
      await rebuild(tester, frameData);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Draggable<UniqueKey>).first),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(100, 100));
      await tester.pump();
      expect(
        find.byType(FrameReorderDragTarget).evaluate().length,
        equals(frameData.state.frames.length - 1),
      );

      await gesture.moveTo(
        tester.getCenter(find.byType(FrameReorderDragTarget).at(1)),
      );
      await gesture.up();

      expect(frameData.state.frames[2].key, equals(reorderingFrameKey));
    },
  );
  testWidgets('FrameTimeline reorder last frame to first with drag and drop', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 200));
    final frameData = FrameData(onFrameDataChange: (_) {});
    frameData.addFrame();
    frameData.addFrame();
    frameData.addFrame();
    frameData.addFrame();
    final reorderingFrameKey = frameData.state.frames.last.key;
    await rebuild(tester, frameData);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Draggable<UniqueKey>).last),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(100, 100));
    await tester.pump();
    expect(
      find.byType(FrameReorderDragTarget).evaluate().length,
      equals(frameData.state.frames.length - 1),
    );

    await gesture.moveTo(
      tester.getCenter(find.byType(FrameReorderDragTarget).first),
    );
    await gesture.up();

    expect(frameData.state.frames.first.key, equals(reorderingFrameKey));
  });
  testWidgets('FrameTimeline delete frame with context menu', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 200));
    final frameData = FrameData(onFrameDataChange: (_) {});
    frameData.addFrame();
    final remainingFrameAfterDelete = frameData.state.frames.last;
    await rebuild(tester, frameData);

    await tester.tap(
      find.byType(FrameThumbnail).first,
      buttons: kSecondaryButton,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await tester.tap(
      find.byType(FrameMenuOptionListItem),
      kind: PointerDeviceKind.mouse,
    );

    expect(frameData.state.frames.length, equals(1));
    expect(frameData.state.frames.first, equals(remainingFrameAfterDelete));
  });
  testWidgets('FrameTimeline unable to delete last frame', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 200));
    final states = [];
    final frameData = FrameData(onFrameDataChange: states.add);
    await rebuild(tester, frameData);

    await tester.tap(
      find.byType(FrameThumbnail).first,
      buttons: kSecondaryButton,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await tester.tap(
      find.byType(FrameMenuOptionListItem),
      kind: PointerDeviceKind.mouse,
    );

    expect(frameData.state.frames.length, equals(1));
    expect(states.length, equals(1));
  });
}
