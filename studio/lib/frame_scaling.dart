import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mls_api/api_types.dart';

import 'editor_dimensions.dart';
import 'entity_edge.dart';

class EntityProjection {
  final Offset offset;
  final Size size;

  const EntityProjection(this.offset, this.size);

  EntityProjection.fromOffset(this.offset) : size = Size.zero;

  @override
  String toString() {
    return 'EntityProjection{offset: $offset, size: $size}';
  }
}

class FrameScaling {
  final Offset frameOffset;
  final Size frameSize;

  FrameScaling({required this.frameOffset, required this.frameSize});

  FrameScaling.fromEditorDimensions(EditorDimensions editorDimensions)
      : frameOffset = editorDimensions.frameOffset,
        frameSize = editorDimensions.frameSize;

  EntityProjection projectEntity(Entity entity) {
    return EntityProjection(
        projectOffset(entity.offset), projectSize(entity.size));
  }

  Offset projectOffset(Offset offset) {
    assert(
        offset.dx <= 1 && offset.dx >= 0 && offset.dy <= 1 && offset.dy >= 0);
    return Offset(offset.dx * frameSize.width, offset.dy * frameSize.height);
  }

  Size projectSize(Size size) {
    assert(size.width <= 1 &&
        size.width >= 0 &&
        size.height <= 1 &&
        size.height >= 0);
    return Size(size.width * frameSize.width, size.height * frameSize.height);
  }

  Offset reverseOffsetProjection(EntityProjection projection) {
    return Offset(projection.offset.dx / frameSize.width,
        projection.offset.dy / frameSize.height);
  }

  Size reverseSizeProjection(EntityProjection projection) {
    return Size(projection.size.width / frameSize.width,
        projection.size.height / frameSize.height);
  }

  EntityProjection clampEntityMove(EntityProjection projection, Offset moving) {
    return EntityProjection(
      _clampFramePosition(projection.offset + moving,
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
    return _clampFramePosition(panePosition - frameOffset,
        entitySize: entitySize);
  }

  Offset _clampFramePosition(Offset framePosition, {required Size entitySize}) {
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
    return 'FrameScaling{frameOffset: $frameOffset, frameSize: $frameSize}';
  }
}
