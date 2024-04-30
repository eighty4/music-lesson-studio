import 'dart:math';

import 'package:flutter/widgets.dart';

import 'aspect_ratio.dart';
import 'editor_toolbar.dart';
import 'entity_data.dart';
import 'entity_edge.dart';

class FrameScaling {
  static Size calculateFrameSize(Size size, double ratio) {
    late final double height;
    late final double width;
    if (size.width / size.height > ratio) {
      height = .8 * size.height;
      width = ratio * height;
    } else {
      width = .8 * size.width;
      height = width / ratio;
    }
    return Size(width, height);
  }

  static Offset calculateFrameOffset(Size paneSize, Size frameSize) {
    final frameOffset = Offset((paneSize.width - frameSize.width) / 2,
        (paneSize.height - frameSize.height) / 2);
    return frameOffset;
  }

  final FrameAspectRatio aspectRatio;
  final Size editorSize;
  late final Offset frameOffset;
  late final Size frameSize;
  late final Size timelineSize;

  FrameScaling(
      {required this.aspectRatio,
      required this.editorSize,
      required bool singleFrame}) {
    timelineSize = singleFrame
        ? Size(editorSize.width, (editorSize.height * .1).clamp(50, 70))
        : Size(editorSize.width, (editorSize.height * .175).clamp(80, 120));
    final paneSize = Size(editorSize.width,
        editorSize.height - EditorToolbar.height - timelineSize.height);
    frameSize = FrameScaling.calculateFrameSize(paneSize, aspectRatio.ratio());
    frameOffset = FrameScaling.calculateFrameOffset(paneSize, frameSize);
  }

  factory FrameScaling.fromConstraints(BoxConstraints constraints,
      {required FrameAspectRatio aspectRatio, required bool singleFrame}) {
    return FrameScaling(
        aspectRatio: aspectRatio,
        editorSize: Size(constraints.maxWidth, constraints.maxHeight),
        singleFrame: singleFrame);
  }

  Offset clampEntityMove(Entity entity, Offset moving) {
    return clampFramePosition(entity.offset + moving, entitySize: entity.size);
  }

  (Offset, Size) clampEntityResize(
      Entity entity, EntityEdge edge, Offset resize) {
    late final double x;
    late final double y;
    late final double w;
    late final double h;
    if (edge.isRight()) {
      x = entity.offset.dx;
      w = min(
          frameSize.width - entity.offset.dx, entity.size.width + resize.dx);
    } else if (edge.isLeft()) {
      x = max(0, entity.offset.dx + resize.dx);
      if (x == 0) {
        w = entity.offset.dx + entity.size.width;
      } else {
        w = entity.size.width - resize.dx;
      }
    } else {
      x = entity.offset.dx;
      w = entity.size.width;
    }
    if (edge.isBottom()) {
      y = entity.offset.dy;
      h = min(
          frameSize.height - entity.offset.dy, entity.size.height + resize.dy);
    } else if (edge.isTop()) {
      y = max(0, entity.offset.dy + resize.dy);
      if (y == 0) {
        h = entity.offset.dy + entity.size.height;
      } else {
        h = entity.size.height - resize.dy;
      }
    } else {
      y = entity.offset.dy;
      h = entity.size.height;
    }
    return (Offset(x, y), Size(w, h));
  }

  Offset clampPanePosition(Offset panePosition, {required Size entitySize}) {
    return clampFramePosition(panePosition - frameOffset,
        entitySize: entitySize);
  }

  Offset clampFramePosition(Offset framePosition, {required Size entitySize}) {
    late final double x;
    if (framePosition.dx < 0) {
      x = 0;
    } else if (framePosition.dx + entitySize.width > frameSize.width) {
      x = frameSize.width - entitySize.width;
    } else {
      x = framePosition.dx;
    }
    late final double y;
    if (framePosition.dy < 0) {
      y = 0;
    } else if (framePosition.dy + entitySize.height > frameSize.height) {
      y = frameSize.height - entitySize.height;
    } else {
      y = framePosition.dy;
    }
    return Offset(x, y);
  }

  @override
  String toString() {
    return 'FrameScaling{aspectRatio: $aspectRatio, editorSize: $editorSize, frameOffset: $frameOffset, frameSize: $frameSize, timelineSize: $timelineSize}';
  }
}
