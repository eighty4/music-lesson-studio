import 'dart:math';

import 'package:flutter/widgets.dart';

import 'aspect_ratio.dart';
import 'editor_toolbar.dart';
import 'entity_data.dart';
import 'entity_edge.dart';

class EntityProjection {
  final Offset offset;
  final Size size;

  const EntityProjection(this.offset, this.size);

  EntityProjection.fromOffset(this.offset) : size = Size.zero;
}

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

  EntityProjection projectEntity(Entity entity) {
    return EntityProjection(
        projectOffset(entity.offset), projectSize(entity.size));
  }

  // todo adjust for 4:3 and 16:9
  Offset projectOffset(Offset offset) {
    assert(
        offset.dx <= 1 && offset.dx >= 0 && offset.dy <= 1 && offset.dy >= 0);
    return Offset(offset.dx * frameSize.width, offset.dy * frameSize.height);
  }

  // todo adjust for 4:3 and 16:9
  Size projectSize(Size size) {
    assert(size.width <= 1 &&
        size.width >= 0 &&
        size.height <= 1 &&
        size.height >= 0);
    return Size(size.width * frameSize.width, size.height * frameSize.height);
  }

  // todo adjust for 4:3 and 16:9
  Offset reverseOffsetProjection(EntityProjection projection) {
    return Offset(projection.offset.dx / frameSize.width,
        projection.offset.dy / frameSize.height);
  }

  // todo adjust for 4:3 and 16:9
  Size reverseSizeProjection(EntityProjection projection) {
    return Size(projection.size.width / frameSize.width,
        projection.size.height / frameSize.height);
  }

  EntityProjection clampEntityMove(EntityProjection projection, Offset moving) {
    return EntityProjection(
      clampFramePosition(projection.offset + moving,
          entitySize: projection.size),
      projection.size,
    );
  }

  EntityProjection clampEntityResize(
      EntityProjection projection, EntityEdge edge, Offset resize) {
    late final double x;
    late final double y;
    late final double w;
    late final double h;
    if (edge.isRight()) {
      x = projection.offset.dx;
      w = min(frameSize.width - projection.offset.dx,
          projection.size.width + resize.dx);
    } else if (edge.isLeft()) {
      x = max(0, projection.offset.dx + resize.dx);
      if (x == 0) {
        w = projection.offset.dx + projection.size.width;
      } else {
        w = projection.size.width - resize.dx;
      }
    } else {
      x = projection.offset.dx;
      w = projection.size.width;
    }
    if (edge.isBottom()) {
      y = projection.offset.dy;
      h = min(frameSize.height - projection.offset.dy,
          projection.size.height + resize.dy);
    } else if (edge.isTop()) {
      y = max(0, projection.offset.dy + resize.dy);
      if (y == 0) {
        h = projection.offset.dy + projection.size.height;
      } else {
        h = projection.size.height - resize.dy;
      }
    } else {
      y = projection.offset.dy;
      h = projection.size.height;
    }
    return EntityProjection(Offset(x, y), Size(w, h));
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
