import 'dart:async';
import 'dart:ui';

import 'package:mls_ui/entity_data.dart';
import 'package:mls_ui/widget_edge.dart';

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
    entity.offset += offset;
    _currentFrame.add(frames[_currentFrameIndex]);
  }

  static resizeEntity(Entity entity, WidgetEdge edge, Offset resize) {
    final (offset, size) =
        calculateResize(edge, entity.offset, entity.size, resize);
    entity.offset = offset;
    entity.size = size;
    _currentFrame.add(frames[_currentFrameIndex]);
  }
}
