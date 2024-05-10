import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mls_studio/api_types.dart';
import 'package:mls_studio/frame_data.dart';

void main() {
  test('reorderFrame', () {
    testReorderFrame(from: 3, to: 2, result: [1, 2, 4, 3, 5]);
    testReorderFrame(from: 1, to: 4, result: [1, 3, 4, 5, 2]);
    testReorderFrame(from: 0, to: 4, result: [2, 3, 4, 5, 1]);
    testReorderFrame(from: 0, to: 3, result: [2, 3, 4, 1, 5]);
  });
}

testReorderFrame(
    {required int from, required int to, required List<int> result}) {
  final frameData = FrameData();
  frameData.createNewFrame();
  frameData.createNewFrame();
  frameData.createNewFrame();
  frameData.createNewFrame();
  assert(frameData.state.frames.length == 5);
  for (var i = 0; i < 5; i++) {
    frameData.changeCurrentFrameByIndex(i);
    frameData.addEntity(Entity(
        type: EntityType.measureChart,
        offset: Offset.zero,
        size: Size(i + 1, i + 1)));
  }

  frameData.reorderFrame(from, to);

  for (var i = 0; i < result.length; i++) {
    expect(
        frameData.state.frames[i].entities[0].size.height, equals(result[i]));
  }
}
