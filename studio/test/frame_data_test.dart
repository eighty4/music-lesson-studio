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
  FrameData.frames.add(Frame());
  FrameData.frames.add(Frame());
  FrameData.frames.add(Frame());
  FrameData.frames.add(Frame());
  FrameData.frames.add(Frame());
  FrameData.deleteFrame(0);
  assert(result.length == FrameData.frames.length);
  FrameData.frames[0].entities.add(Entity(
      type: EntityType.measureChart,
      offset: Offset.zero,
      size: const Size(1, 1)));
  FrameData.frames[1].entities.add(Entity(
      type: EntityType.measureChart,
      offset: Offset.zero,
      size: const Size(2, 2)));
  FrameData.frames[2].entities.add(Entity(
      type: EntityType.measureChart,
      offset: Offset.zero,
      size: const Size(3, 3)));
  FrameData.frames[3].entities.add(Entity(
      type: EntityType.measureChart,
      offset: Offset.zero,
      size: const Size(4, 4)));
  FrameData.frames[4].entities.add(Entity(
      type: EntityType.measureChart,
      offset: Offset.zero,
      size: const Size(5, 5)));

  FrameData.reorderFrame(from, to);

  for (var i = 0; i < result.length; i++) {
    expect(FrameData.frames[i].entities[0].size.height, equals(result[i]));
  }

  FrameData.createNewFrame(insertFrameIndex: 0);
  FrameData.deleteFrame(1);
  FrameData.deleteFrame(1);
  FrameData.deleteFrame(1);
  FrameData.deleteFrame(1);
  FrameData.deleteFrame(1);
}
