import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'entity_data.dart';
import 'entity_edge.dart';
import 'frame_scaling.dart';

class Frame {
  final List<Entity> entities = [];
}

class FrameData {
  static final List<Frame> _frames = [Frame()];
  static int _currentFrameIndex = 0;

  static final StreamController<Frame> _currentFrameStream =
      StreamController.broadcast();

  static final StreamController<List<Frame>> _allFramesStream =
      StreamController.broadcast();

  static Stream<Frame> get currentFrameStream => _currentFrameStream.stream;

  static Stream<List<Frame>> get allFramesStream => _allFramesStream.stream;

  static Frame get currentFrame => _frames[_currentFrameIndex];

  static List<Frame> get frames => _frames;

  static _updateStreams() {
    _allFramesStream.add(_frames);
    _currentFrameStream.add(_frames[_currentFrameIndex]);
  }

  static createNewFrame() {
    _frames.add(Frame());
    _currentFrameIndex = _frames.length - 1;
    _updateStreams();
  }

  static changeCurrentFrame(Frame frame) {
    final index = _frames.indexOf(frame);
    assert(index != -1);
    _currentFrameIndex = index;
    _updateStreams();
  }

  // todo center adding entity on cursor
  static addEntity(Entity entity) {
    _frames[_currentFrameIndex].entities.add(entity);
    _updateStreams();
  }

  static moveEntity(Entity entity, FrameScaling frameScaling, Offset moving) {
    final frame = _frames[_currentFrameIndex];
    final entityIndex = frame.entities.indexOf(entity);
    frame.entities[entityIndex] = Entity(
        type: entity.type,
        offset: frameScaling.clampEntityMove(entity, moving),
        size: entity.size);
    _updateStreams();
  }

  static resizeEntity(Entity entity, FrameScaling frameScaling, EntityEdge edge,
      Offset resizing) {
    final frame = _frames[_currentFrameIndex];
    final entityIndex = frame.entities.indexOf(entity);
    final (offset, size) =
        frameScaling.clampEntityResize(entity, edge, resizing);
    frame.entities[entityIndex] =
        Entity(type: entity.type, offset: offset, size: size);
    _updateStreams();
  }

  static deleteEntity(UniqueKey entityKey) {
    final frame = frames[_currentFrameIndex];
    frame.entities.removeAt(
        frame.entities.indexWhere((entity) => entity.key == entityKey));
    _updateStreams();
  }
}
