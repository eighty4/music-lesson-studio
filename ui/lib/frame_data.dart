import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'entity_data.dart';

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

  static createNewFrame({int? insertFrameIndex}) {
    if (insertFrameIndex != null) {
      assert(insertFrameIndex <= _frames.length);
      _frames.insert(insertFrameIndex, Frame());
      _currentFrameIndex = insertFrameIndex;
    } else {
      _frames.add(Frame());
      _currentFrameIndex = _frames.length - 1;
    }
    _updateStreams();
  }

  static changeCurrentFrame(Frame frame) {
    final index = _frames.indexOf(frame);
    assert(index != -1);
    _currentFrameIndex = index;
    _updateStreams();
  }

  static deleteFrame(int frameIndex) {
    assert(frameIndex != -1);
    _frames.removeAt(frameIndex);
    if (_currentFrameIndex == frameIndex) {
      _currentFrameIndex--;
    }
    _updateStreams();
  }

  // todo center adding entity on cursor
  static addEntity(Entity entity) {
    _frames[_currentFrameIndex].entities.add(entity);
    _updateStreams();
  }

  static moveEntity(UniqueKey entityKey, Offset offset) {
    final frame = _frames[_currentFrameIndex];
    final entityIndex =
        frame.entities.indexWhere((entity) => entity.key == entityKey);
    final entity = frame.entities[entityIndex];
    frame.entities[entityIndex] =
        Entity(type: entity.type, offset: offset, size: entity.size);
    _updateStreams();
  }

  static resizeEntity(UniqueKey entityKey, Offset offset, Size size) {
    final frame = _frames[_currentFrameIndex];
    final entityIndex =
        frame.entities.indexWhere((entity) => entity.key == entityKey);
    final entity = frame.entities[entityIndex];
    frame.entities[entityIndex] = Entity(
      type: entity.type,
      offset: offset,
      size: size,
    );
    _updateStreams();
  }

  static deleteEntity(UniqueKey entityKey) {
    final frame = frames[_currentFrameIndex];
    frame.entities.removeAt(
        frame.entities.indexWhere((entity) => entity.key == entityKey));
    _updateStreams();
  }
}
