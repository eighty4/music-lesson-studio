import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mls_ui/entity_data.dart';
import 'package:mls_ui/entity_edge.dart';
import 'package:mls_ui/frame_scaling.dart';

class Frame {
  final List<Entity> entities = [];
}

class FrameData {
  static final List<Frame> frames = [Frame()];
  static const int _currentFrameIndex = 0;

  static final StreamController<Frame> _currentFrame =
      StreamController.broadcast();

  static Stream<Frame> get currentFrame => _currentFrame.stream;

  // todo center adding entity on cursor
  static addEntity(EntityType type, FrameScaling frameScaling) {
    final size = type.defaultSize();
    final entity = Entity(
        type: type,
        offset: frameScaling.clampPanePosition(entitySize: size),
        size: size);
    final frame = frames[_currentFrameIndex];
    frame.entities.add(entity);
    _currentFrame.add(frame);
  }

  static moveEntity(Entity entity, FrameScaling frameScaling, Offset moving) {
    entity.offset = frameScaling.clampEntityMove(entity, moving);
    _currentFrame.add(frames[_currentFrameIndex]);
  }

  static resizeEntity(Entity entity, FrameScaling frameScaling, EntityEdge edge,
      Offset resizing) {
    final (offset, size) =
        frameScaling.clampEntityResize(entity, edge, resizing);
    entity.offset = offset;
    entity.size = size;
    _currentFrame.add(frames[_currentFrameIndex]);
  }

  static deleteEntity(UniqueKey entityKey) {
    final frame = frames[_currentFrameIndex];
    frame.entities.removeAt(
        frame.entities.indexWhere((entity) => entity.key == entityKey));
    _currentFrame.add(frame);
  }
}
