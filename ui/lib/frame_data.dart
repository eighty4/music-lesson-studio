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

// todo property map to translate between serializable and widget
class Entity {
  final UniqueKey key;
  final EntityType type;
  final double x;
  final double y;
  final Size size;

  Entity(
      {required this.type,
      required this.x,
      required this.y,
      required this.size})
      : key = UniqueKey();
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
}
