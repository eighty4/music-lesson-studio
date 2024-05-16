import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libtab/context.dart';
import 'package:mls_studio/frame_data.dart';
import 'package:mls_studio/frame_timeline.dart';

final tabContext = TabContext.forBrightness(Brightness.dark);

rebuild(WidgetTester tester, FrameData frameData) async {
  await tester.pumpWidget(InheritedFrameData(
    frameData: frameData,
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: FrameTimeline(
              currentFrame: frameData.state.currentFrame,
              frames: frameData.state.frames,
              height: 50,
              tabContext: tabContext),
        ),
      ),
    ),
  ));
}

void main() {
  testWidgets('FrameTimeline adds frame', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 200));
    final frameData = FrameData(onFrameDataChange: (_) {});
    await rebuild(tester, frameData);

    await tester.tap(find.byType(AddFrameButton).first,
        buttons: kPrimaryButton, kind: PointerDeviceKind.mouse);
    await tester.pump();

    expect(frameData.state.frames.length, equals(2));
  });
  testWidgets('FrameTimeline unable to add more than max frames',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 200));
    final frameData = FrameData(onFrameDataChange: (_) {});
    await rebuild(tester, frameData);

    while (frameData.state.frames.length < FrameData.maxFrames) {
      await tester.tap(find.byType(AddFrameButton).first,
          buttons: kPrimaryButton, kind: PointerDeviceKind.mouse);
      await tester.pump();
    }

    await rebuild(tester, frameData);
    expect(find.byType(AddFrameButton), findsNothing);
  });
}
