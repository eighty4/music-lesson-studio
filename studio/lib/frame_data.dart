import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mls_api/api_types.dart';

extension on Frame {
  Frame mutateEntity(UniqueKey entityKey, Entity Function(Entity) mutateFn) {
    assert(entities.where((e) => e.key == entityKey).firstOrNull != null);
    return Frame(
        key: key,
        entities: entities.map(
            (entity) => entity.key == entityKey ? mutateFn(entity) : entity));
  }
}

extension MutateEntityFn on Entity {
  Entity mutate({Offset? offset, Size? size}) => Entity(
      key: key,
      type: type,
      offset: offset ?? this.offset,
      size: size ?? this.size);
}

class FrameDataState {
  final List<Frame> frames;
  final Frame currentFrame;

  FrameDataState({required Iterable<Frame> frames, required this.currentFrame})
      : frames = List.of(frames, growable: false) {
    assert(this.frames.isNotEmpty);
    assert(this.frames.contains(currentFrame));
    assert(this
        .frames
        .where((frame) => identical(frame, currentFrame))
        .isNotEmpty);
  }

  factory FrameDataState.initial() {
    return FrameDataState.fromFrames([Frame()]);
  }

  factory FrameDataState.fromFrames(
    List<Frame> frames, {
    Frame? currentFrame,
    UniqueKey? currentFrameKey,
  }) {
    assert(frames.isNotEmpty);
    assert(currentFrameKey == null || currentFrame == null);
    assert(currentFrameKey == null ||
        frames.map((frame) => frame.key).contains(currentFrameKey));
    return FrameDataState(
        frames: frames,
        currentFrame: currentFrame ??
            (currentFrameKey == null
                ? frames.first
                : frames.firstWhere((frame) => frame.key == currentFrameKey)));
  }

  Entity getEntityByKey(UniqueKey frameKey, UniqueKey entityKey) {
    for (final frame in frames) {
      if (frame.key == frameKey) {
        for (final entity in frame.entities) {
          if (entity.key == entityKey) {
            return entity;
          }
        }
      }
    }
    throw ArgumentError();
  }

  FrameDataState addEntity(UniqueKey frameKey, Entity entity) {
    return mutateFrame(
        frameKey,
        (frame) =>
            Frame(key: frame.key, entities: [...frame.entities, entity]));
  }

  FrameDataState removeEntity(UniqueKey frameKey, UniqueKey entityKey) {
    return mutateFrame(frameKey, (frame) {
      return Frame(
          key: frame.key,
          entities: frame.entities.where((entity) => entity.key != entityKey));
    });
  }

  FrameDataState mutateEntity(UniqueKey frameKey, UniqueKey entityKey,
      {Offset? offset, Size? size}) {
    assert(offset != null || size != null);
    return mutateFrame(
        frameKey,
        (frame) => frame.mutateEntity(
            entityKey, (entity) => entity.mutate(offset: offset, size: size)));
  }

  FrameDataState mutateFrame(
      UniqueKey frameKey, Frame Function(Frame) mutateFn) {
    assert(this.frames.where((f) => f.key == frameKey).firstOrNull != null);
    late final Frame currentFrame;
    final List<Frame> frames = this
        .frames
        .map((frame) =>
            frame.key == frameKey ? currentFrame = mutateFn(frame) : frame)
        .toList();
    return FrameDataState.fromFrames(frames, currentFrame: currentFrame);
  }

  @override
  String toString() {
    return 'FrameDataState{frames: ${frames.map((frame) => frame.key)}, currentFrame: ${currentFrame.key}}';
  }
}

abstract class FrameCommand {
  FrameDataState exec(FrameDataState state);

  FrameDataState undo(FrameDataState state);
}

class _CommandStackThatAlsoDoesUndoesAndRedoes {
  final List<FrameCommand> undoStack = [];
  final List<FrameCommand> redoStack = [];

  _CommandStackThatAlsoDoesUndoesAndRedoes.namingThingsIsHard();

  FrameDataState exec(FrameCommand command, FrameDataState state) {
    if (kDebugMode) {
      print('exec $command');
      print('exec ${command.runtimeType} state before: $state');
    }
    redoStack.clear();
    undoStack.add(command);
    final result = command.exec(state);
    if (kDebugMode) {
      print('executed $command');
      print('exec ${command.runtimeType} state after: $result');
    }
    return result;
  }

  FrameDataState? undo(FrameDataState state) {
    if (undoStack.isEmpty) {
      return null;
    }
    final command = undoStack.removeLast();
    if (kDebugMode) {
      print('undo $command');
      print('undo ${command.runtimeType} state before: $state');
    }
    redoStack.add(command);
    final result = command.undo(state);
    if (kDebugMode) {
      print('undid $command');
      print('undo ${command.runtimeType} state after: $result');
    }
    return result;
  }

  FrameDataState? redo(FrameDataState state) {
    if (redoStack.isEmpty) {
      return null;
    }
    final command = redoStack.removeLast();
    if (kDebugMode) {
      print('redo $command');
      print('redo ${command.runtimeType} state before: $state');
    }
    undoStack.add(command);
    final result = command.exec(state);
    if (kDebugMode) {
      print('redid $command');
      print('redo ${command.runtimeType} state after: $result');
    }
    return result;
  }
}

typedef FrameDataCallback = void Function(FrameDataState);

class FrameData {
  static const maxFrames = 5;

  static FrameData of(BuildContext context) {
    final inheritedFrameData =
        context.dependOnInheritedWidgetOfExactType<InheritedFrameData>();
    assert(inheritedFrameData != null);
    return inheritedFrameData!.frameData;
  }

  final FrameDataCallback _callback;

  final _CommandStackThatAlsoDoesUndoesAndRedoes _commands =
      _CommandStackThatAlsoDoesUndoesAndRedoes.namingThingsIsHard();

  FrameDataState _state = FrameDataState.initial();

  FrameData({required FrameDataCallback onFrameDataChange})
      : _callback = onFrameDataChange;

  FrameDataState get state => _state;

  void _exec(FrameCommand command) => _update(_commands.exec(command, _state));

  void _update(FrameDataState state) => _callback(_state = state);

  void _maybeUpdate(FrameDataState? state) =>
      {if (state != null) _update(state)};

  void undo() => _maybeUpdate(_commands.undo(_state));

  void redo() => _maybeUpdate(_commands.redo(_state));

  void changeCurrentFrame(Frame frame) => _update(FrameDataState(
        frames: _state.frames,
        currentFrame: frame,
      ));

  void addFrame({UniqueKey? beforeFrame, UniqueKey? afterFrame}) =>
      _exec(_AddFrameCommand(beforeFrame: beforeFrame, afterFrame: afterFrame));

  void deleteFrame(UniqueKey frameKey) =>
      _exec(_DeleteFrameCommand(frameKey: frameKey));

  void reorderFrame(UniqueKey frameKey,
          {UniqueKey? beforeFrame, UniqueKey? afterFrame}) =>
      _exec(_ReorderFrameCommand(frameKey,
          beforeFrame: beforeFrame, afterFrame: afterFrame));

  void addEntity(Entity entity) =>
      _exec(_AddEntityCommand(entity, frameKey: _state.currentFrame.key));

  void moveEntity(Entity entity, Offset offset) => _exec(_MoveEntityCommand(
      entityKey: entity.key,
      frameKey: state.currentFrame.key,
      moveTo: offset,
      moveFrom: entity.offset));

  void resizeEntity(Entity entity, Offset offset, Size size) =>
      _exec(_ResizeEntityCommand(
          entityKey: entity.key,
          frameKey: state.currentFrame.key,
          resizeTo: (offset, size),
          resizeFrom: (entity.offset, entity.size)));

  void deleteEntity(UniqueKey entityKey) => _exec(_DeleteEntityCommand(
      entityKey: entityKey, frameKey: state.currentFrame.key));
}

class _AddFrameCommand implements FrameCommand {
  final UniqueKey? beforeFrame;
  final UniqueKey? afterFrame;
  final Frame frameToAdd;
  UniqueKey? _undoCurrentFrameKey;

  _AddFrameCommand({this.beforeFrame, this.afterFrame, Frame? frame})
      : frameToAdd = frame ?? Frame() {
    assert(beforeFrame == null || afterFrame == null);
    assert(frameToAdd.key != beforeFrame && frameToAdd.key != afterFrame);
  }

  @override
  FrameDataState exec(FrameDataState state) {
    assert(state.frames.length <= FrameData.maxFrames);
    final frames = [...state.frames];
    _undoCurrentFrameKey = state.currentFrame.key;
    if (beforeFrame != null) {
      final beforeIndex =
          frames.indexWhere((frame) => frame.key == beforeFrame);
      assert(beforeIndex != -1);
      frames.insert(beforeIndex, frameToAdd);
    } else if (afterFrame != null) {
      final afterIndex = frames.indexWhere((frame) => frame.key == afterFrame);
      assert(afterIndex != -1);
      frames.insert(afterIndex + 1, frameToAdd);
    } else {
      frames.add(frameToAdd);
    }
    return FrameDataState.fromFrames(frames, currentFrame: frameToAdd);
  }

  @override
  FrameDataState undo(FrameDataState state) {
    final frames =
        state.frames.where((frame) => frame.key != frameToAdd.key).toList();
    return FrameDataState.fromFrames(frames,
        currentFrameKey: _undoCurrentFrameKey);
  }

  @override
  String toString() {
    return '_AddFrameCommand{beforeFrame: $beforeFrame, afterFrame: $afterFrame, _added: $frameToAdd}';
  }
}

class _ReorderFrameCommand implements FrameCommand {
  final UniqueKey frameKey;
  final UniqueKey? beforeFrame;
  final UniqueKey? afterFrame;
  int? undoIndex;

  _ReorderFrameCommand(this.frameKey,
      {required this.beforeFrame, required this.afterFrame}) {
    assert([beforeFrame, afterFrame].where((v) => v != null).length == 1);
    assert(frameKey != afterFrame && frameKey != beforeFrame);
  }

  @override
  FrameDataState exec(FrameDataState state) {
    assert(undoIndex == null);
    final frames = [...state.frames];
    final reorderingFrame = frames.removeAt(
        undoIndex = frames.indexWhere((frame) => frame.key == frameKey));
    late final int insertIndex;
    if (beforeFrame != null) {
      insertIndex = frames.indexWhere((frame) => frame.key == beforeFrame);
      assert(insertIndex != -1);
    } else {
      insertIndex = frames.indexWhere((frame) => frame.key == afterFrame) + 1;
      assert(insertIndex != 0);
    }
    frames.insert(insertIndex, reorderingFrame);
    return FrameDataState.fromFrames(frames, currentFrameKey: frameKey);
  }

  @override
  FrameDataState undo(FrameDataState state) {
    assert(undoIndex != null);
    final frames = [...state.frames];
    final reorderingFrame =
        frames.removeAt(frames.indexWhere((frame) => frame.key == frameKey));
    frames.insert(undoIndex!, reorderingFrame);
    undoIndex = null;
    return FrameDataState.fromFrames(frames, currentFrameKey: frameKey);
  }

  @override
  String toString() {
    return '_ReorderFrameCommand{frameKey: $frameKey, beforeFrame: $beforeFrame, afterFrame: $afterFrame}';
  }
}

class _DeleteFrameCommand implements FrameCommand {
  final UniqueKey frameKey;
  _AddFrameCommand? _undoCommand;

  _DeleteFrameCommand({required this.frameKey});

  @override
  FrameDataState exec(FrameDataState state) {
    assert(state.frames.length > 1);
    final List<Frame> frames = [];
    late final int currentFrameIndex;
    for (var i = 0; i < state.frames.length; i++) {
      final frame = state.frames[i];
      if (frame.key == frameKey) {
        currentFrameIndex = i;
        if (frame == state.frames.last) {
          _undoCommand = _AddFrameCommand(
              frame: frame,
              afterFrame: state.frames[state.frames.length - 2].key);
        } else {
          _undoCommand = _AddFrameCommand(
              frame: frame, beforeFrame: state.frames[i + 1].key);
        }
      } else {
        frames.add(frame);
      }
    }
    assert(_undoCommand != null);
    return FrameDataState.fromFrames(frames,
        currentFrame: frames[min(currentFrameIndex, frames.length - 1)]);
  }

  @override
  FrameDataState undo(FrameDataState state) {
    assert(_undoCommand != null);
    return _undoCommand!.exec(state);
  }

  @override
  String toString() {
    return '_DeleteFrameCommand{frameKey: $frameKey, _undoCommand: $_undoCommand}';
  }
}

class _AddEntityCommand implements FrameCommand {
  final Entity entity;
  final UniqueKey frameKey;

  _AddEntityCommand(this.entity, {required this.frameKey});

  @override
  FrameDataState exec(FrameDataState state) {
    return state.addEntity(frameKey, entity);
  }

  @override
  FrameDataState undo(FrameDataState state) {
    return state.removeEntity(frameKey, entity.key);
  }

  @override
  String toString() {
    return '_AddEntityCommand{entity: $entity, frameKey: $frameKey}';
  }
}

class _MoveEntityCommand implements FrameCommand {
  final UniqueKey entityKey;
  final UniqueKey frameKey;
  final Offset moveTo;
  final Offset moveFrom;

  _MoveEntityCommand(
      {required this.entityKey,
      required this.frameKey,
      required this.moveTo,
      required this.moveFrom});

  @override
  FrameDataState exec(FrameDataState state) {
    return state.mutateEntity(frameKey, entityKey, offset: moveTo);
  }

  @override
  FrameDataState undo(FrameDataState state) {
    return state.mutateEntity(frameKey, entityKey, offset: moveFrom);
  }

  @override
  String toString() {
    return '_MoveEntityCommand{entityKey: $entityKey, frameKey: $frameKey, moveTo: $moveTo, moveFrom: $moveFrom}';
  }
}

class _ResizeEntityCommand implements FrameCommand {
  final UniqueKey entityKey;
  final UniqueKey frameKey;
  final (Offset, Size) resizeTo;
  final (Offset, Size) resizeFrom;

  _ResizeEntityCommand(
      {required this.entityKey,
      required this.frameKey,
      required this.resizeTo,
      required this.resizeFrom});

  @override
  FrameDataState exec(FrameDataState state) {
    return state.mutateEntity(frameKey, entityKey,
        offset: resizeTo.$1, size: resizeTo.$2);
  }

  @override
  FrameDataState undo(FrameDataState state) {
    return state.mutateEntity(frameKey, entityKey,
        offset: resizeFrom.$1, size: resizeFrom.$2);
  }

  @override
  String toString() {
    return '_ResizeEntityCommand{entityKey: $entityKey, frameKey: $frameKey, resizeTo: $resizeTo, resizeFrom: $resizeFrom}';
  }
}

class _DeleteEntityCommand implements FrameCommand {
  final UniqueKey entityKey;
  final UniqueKey frameKey;
  Entity? _deleted;

  _DeleteEntityCommand({required this.entityKey, required this.frameKey});

  @override
  FrameDataState exec(FrameDataState state) {
    _deleted = state.getEntityByKey(frameKey, entityKey);
    return state.removeEntity(frameKey, entityKey);
  }

  @override
  FrameDataState undo(FrameDataState state) {
    assert(_deleted != null);
    return state.addEntity(frameKey, _deleted!);
  }

  @override
  String toString() {
    return '_DeleteEntityCommand{entityKey: $entityKey, frameKey: $frameKey, _deleted: $_deleted}';
  }
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
