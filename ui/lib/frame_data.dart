import 'dart:async';

import 'package:flutter/widgets.dart';

enum EntityType {
  measureChart,
  chordChart,
  paragraphText,
  hypermediaLink,
  imageUpload,
  videoUpload,
  videoRecord,
  youTubeEmbed
}

// todo mutability bad, napster good
// todo property map to translate between serializable and widget
class Entity {
  final UniqueKey key;
  final EntityType type;
  double x;
  double y;
  final Size size;

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
}
