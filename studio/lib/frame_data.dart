import 'package:flutter/widgets.dart';

import 'api_types.dart';

class FrameDataState {
  final List<Frame> frames;
  final int currentFrameIndex;

  FrameDataState({Iterable<Frame>? frames, int? currentFrameIndex})
      : frames = List.of(frames ?? [Frame()], growable: false),
        currentFrameIndex = currentFrameIndex ?? 0;

  Frame get currentFrame => frames[currentFrameIndex];

  FrameDataState createNewFrame({int? insertFrameIndex}) {
    final frames = [...this.frames];
    late final int currentFrameIndex;
    if (insertFrameIndex != null) {
      assert(insertFrameIndex <= frames.length);
      frames.insert(insertFrameIndex, Frame());
      currentFrameIndex = insertFrameIndex;
    } else {
      frames.add(Frame());
      currentFrameIndex = frames.length - 1;
    }
    return FrameDataState(frames: frames, currentFrameIndex: currentFrameIndex);
  }

  FrameDataState changeCurrentFrame(Frame frame) {
    final frameIndex = frames.indexOf(frame);
    assert(frameIndex != -1);
    return changeCurrentFrameByIndex(frameIndex);
  }

  FrameDataState changeCurrentFrameByIndex(int frameIndex) {
    return FrameDataState(
      frames: [...frames],
      currentFrameIndex: frameIndex,
    );
  }

  FrameDataState deleteFrame(int frameIndex) {
    assert(frameIndex != -1);
    assert(frameIndex < this.frames.length);
    if (frameIndex == 0 && this.frames.length == 1) {
      return this;
    }
    final frames = [...this.frames];
    int currentFrameIndex = this.currentFrameIndex;
    frames.removeAt(frameIndex);
    if (currentFrameIndex == frameIndex) {
      if (currentFrameIndex != 0) {
        currentFrameIndex--;
      }
    }
    return FrameDataState(
      frames: frames,
      currentFrameIndex: currentFrameIndex,
    );
  }

  FrameDataState reorderFrame(int frameIndex, int moveFrameIndex) {
    assert(frameIndex <= this.frames.length);
    assert(moveFrameIndex <= this.frames.length);
    assert(frameIndex != moveFrameIndex);
    final frames = [...this.frames];
    final frame = frames.removeAt(frameIndex);
    frames.insert(moveFrameIndex, frame);
    return FrameDataState(frames: frames, currentFrameIndex: currentFrameIndex)
        .changeCurrentFrame(frame);
  }

  // todo center adding entity on cursor
  FrameDataState addEntity(Entity entity) {
    frames[currentFrameIndex].entities.add(entity);
    return FrameDataState(frames: frames, currentFrameIndex: currentFrameIndex);
  }

  FrameDataState moveEntity(UniqueKey entityKey, Offset offset) {
    final frame = frames[currentFrameIndex];
    final entityIndex =
        frame.entities.indexWhere((entity) => entity.key == entityKey);
    assert(entityIndex != -1);
    final entity = frame.entities[entityIndex];
    frame.entities[entityIndex] = Entity(
        key: entity.key, type: entity.type, offset: offset, size: entity.size);
    return FrameDataState(frames: frames, currentFrameIndex: currentFrameIndex);
  }

  FrameDataState resizeEntity(UniqueKey entityKey, Offset offset, Size size) {
    final frame = frames[currentFrameIndex];
    final entityIndex =
        frame.entities.indexWhere((entity) => entity.key == entityKey);
    final entity = frame.entities[entityIndex];
    frame.entities[entityIndex] = Entity(
      type: entity.type,
      offset: offset,
      size: size,
    );
    return FrameDataState(frames: frames, currentFrameIndex: currentFrameIndex);
  }

  FrameDataState deleteEntity(UniqueKey entityKey) {
    frames[currentFrameIndex]
        .entities
        .removeWhere((entity) => entity.key == entityKey);
    return FrameDataState(frames: frames, currentFrameIndex: currentFrameIndex);
  }
}

typedef FrameDataCallback = void Function(FrameDataState);

class FrameData {
  static FrameData of(BuildContext context) {
    final inheritedFrameData =
        context.dependOnInheritedWidgetOfExactType<InheritedFrameData>();
    assert(inheritedFrameData != null);
    return inheritedFrameData!.frameData;
  }

  final FrameDataCallback _callback;

  FrameDataState _state = FrameDataState();

  FrameData({required FrameDataCallback onFrameDataChange})
      : _callback = onFrameDataChange;

  FrameDataState get state => _state;

  void _update(FrameDataState state) => _callback(_state = state);

  void createNewFrame({int? insertFrameIndex}) =>
      _update(_state.createNewFrame(insertFrameIndex: insertFrameIndex));

  void changeCurrentFrame(Frame frame) =>
      _update(_state.changeCurrentFrame(frame));

  void changeCurrentFrameByIndex(int frameIndex) =>
      _update(_state.changeCurrentFrameByIndex(frameIndex));

  void deleteFrame(int frameIndex) {
    _update(_state.deleteFrame(frameIndex));
  }

  void reorderFrame(int frameIndex, int moveFrameIndex) =>
      _update(_state.reorderFrame(frameIndex, moveFrameIndex));

  // todo center adding entity on cursor
  void addEntity(Entity entity) => _update(_state.addEntity(entity));

  void moveEntity(UniqueKey entityKey, Offset offset) =>
      _update(_state.moveEntity(entityKey, offset));

  void resizeEntity(UniqueKey entityKey, Offset offset, Size size) {
    _update(_state.resizeEntity(entityKey, offset, size));
  }

  void deleteEntity(UniqueKey entityKey) =>
      _update(_state.deleteEntity(entityKey));
}

class InheritedFrameData extends InheritedWidget {
  final FrameData frameData;

  const InheritedFrameData(
      {super.key, required super.child, required this.frameData});

  @override
  bool updateShouldNotify(covariant InheritedFrameData oldWidget) {
    return oldWidget.frameData.state != frameData.state;
  }
}
