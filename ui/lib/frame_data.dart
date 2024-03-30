import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mls_ui/widget_edge.dart';

enum EntityType {
  measureChart,
  chordChart,
  paragraphText,
  hypermediaLink,
  imageUpload,
  videoUpload,
  videoRecord,
  youTubeEmbed,
}

// todo mutability bad, napster good
// todo property map to translate between serializable and widget
class Entity {
  final UniqueKey key;
  final EntityType type;
  double x;
  double y;
  Size size;

  Entity(
      {required this.type,
      required this.x,
      required this.y,
      required this.size})
      : key = UniqueKey();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

class Frame {
  final List<Entity> entities = [];
}

class FrameData {
  static final List<Frame> frames = [Frame()];
  static const int _currentFrameIndex = 0;

  static final StreamController<Frame> _currentFrame =
      StreamController.broadcast();

  static Stream<Frame> get currentFrame => _currentFrame.stream;

  static addEntity(Entity entity) {
    final frame = frames[_currentFrameIndex];
    frame.entities.add(entity);
    _currentFrame.add(frame);
  }

  static moveEntity(Entity entity, Offset offset) {
    entity.x += offset.dx;
    entity.y += offset.dy;
    _currentFrame.add(frames[_currentFrameIndex]);
  }

  static resizeEntity(Entity entity, WidgetEdge edge, Offset resize) {
    final (offset, size) =
        calculateResize(edge, Offset(entity.x, entity.y), entity.size, resize);
    entity.x = offset.dx;
    entity.y = offset.dy;
    entity.size = size;
    _currentFrame.add(frames[_currentFrameIndex]);
  }
}

(Offset, Size) calculateResize(
    WidgetEdge? edge, Offset offset, Size size, Offset resize) {
  if (edge == null) {
    return (offset, size);
  }
  late final double x;
  late final double y;
  late final double w;
  late final double h;
  if (edge.isRight()) {
    x = offset.dx;
    w = size.width + resize.dx;
  } else if (edge.isLeft()) {
    x = offset.dx + resize.dx;
    w = size.width - resize.dx;
  } else {
    x = offset.dx;
    w = size.width;
  }
  if (edge.isBottom()) {
    y = offset.dy;
    h = size.height + resize.dy;
  } else if (edge.isTop()) {
    y = offset.dy + resize.dy;
    h = size.height - resize.dy;
  } else {
    y = offset.dy;
    h = size.height;
  }
  return (Offset(x, y), Size(w, h));
}
