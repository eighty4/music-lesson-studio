import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_api/api_types.dart';
import 'package:mls_studio/frame_data.dart';

extension on FrameDataState {
  List<UniqueKey> get frameKeys => frames.map((frame) => frame.key).toList();
}

void main() {
  test('Entity mutate preserves type and key', () {
    final source = Entity.chordChart(
      chord: Chord.c,
      instrument: Instrument.banjo,
      offset: const Offset(867, 5309),
      size: const Size(555, 1239),
    );
    final mutated = source.mutate(
        offset: const Offset(123, 456), size: const Size(789, 101112));
    expect(mutated.key, equals(source.key));
    expect(mutated.type, equals(source.type));
  });
  group('FrameData.addFrame', () {
    group('append', () {
      test('exec', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        expect(states.length, equals(1));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frames.every((frame) => frame.entities.isEmpty),
            equals(true));
      });
      test('undo', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        expect(frameData.state.frames.length, equals(4));
        frameData.undo();
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(3));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.last));
        frameData.undo();
        expect(states.length, equals(5));
        expect(frameData.state.frames.length, equals(2));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.last));
      });
      test('redo', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        expect(frameData.state.frames.length, equals(4));
        frameData.undo();
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(3));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.last));
        frameData.undo();
        expect(states.length, equals(5));
        expect(frameData.state.frames.length, equals(2));
        frameData.redo();
        frameData.redo();
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.last));
        expect(states.length, equals(7));
        expect(frameData.state.frames.length, equals(4));
      });
    });

    group('beforeFrame', () {
      test('exec', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        frameData.addFrame(beforeFrame: frameData.state.frames[2].key);
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(5));
        expect(states[2].frames[0].key, equals(frameData.state.frames[0].key));
        expect(states[2].frames[1].key, equals(frameData.state.frames[1].key));
        expect(states[2].frames[2].key,
            isNot(equals(frameData.state.frames[2].key)));
        expect(states[2].frames[2].key, equals(frameData.state.frames[3].key));
        expect(states[2].frames[3].key, equals(frameData.state.frames[4].key));
      });
      test('undo', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        frameData.addFrame(beforeFrame: frameData.state.frames[2].key);
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(5));
        expect(states[2].frames[0].key, equals(frameData.state.frames[0].key));
        expect(states[2].frames[1].key, equals(frameData.state.frames[1].key));
        expect(states[2].frames[2].key,
            isNot(equals(frameData.state.frames[2].key)));
        expect(states[2].frames[2].key, equals(frameData.state.frames[3].key));
        expect(states[2].frames[3].key, equals(frameData.state.frames[4].key));
        frameData.undo();
        expect(states.length, equals(5));
        expect(frameData.state.frames.length, equals(4));
        expect(frameData.state.frameKeys, equals(states[2].frameKeys));
      });
      test('redo', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        frameData.addFrame(beforeFrame: frameData.state.frames[2].key);
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(5));
        expect(states[2].frames[0].key, equals(frameData.state.frames[0].key));
        expect(states[2].frames[1].key, equals(frameData.state.frames[1].key));
        expect(states[2].frames[2].key,
            isNot(equals(frameData.state.frames[2].key)));
        expect(states[2].frames[2].key, equals(frameData.state.frames[3].key));
        expect(states[2].frames[3].key, equals(frameData.state.frames[4].key));
        frameData.undo();
        expect(states.length, equals(5));
        expect(frameData.state.frames.length, equals(4));
        expect(frameData.state.frameKeys, equals(states[2].frameKeys));
        frameData.redo();
        expect(states.length, equals(6));
        expect(frameData.state.frames.length, equals(5));
        expect(states[2].frames[0].key, equals(frameData.state.frames[0].key));
        expect(states[2].frames[1].key, equals(frameData.state.frames[1].key));
        expect(states[2].frames[2].key,
            isNot(equals(frameData.state.frames[2].key)));
        expect(states[2].frames[2].key, equals(frameData.state.frames[3].key));
        expect(states[2].frames[3].key, equals(frameData.state.frames[4].key));
      });
    });

    group('afterFrame', () {
      test('exec', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        frameData.addFrame(afterFrame: frameData.state.frames[2].key);
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(5));
        expect(states[2].frames[0].key, equals(frameData.state.frames[0].key));
        expect(states[2].frames[1].key, equals(frameData.state.frames[1].key));
        expect(states[2].frames[2].key, equals(frameData.state.frames[2].key));
        expect(states[2].frames[3].key,
            isNot(equals(frameData.state.frames[3].key)));
        expect(states[2].frames[3].key, equals(frameData.state.frames[4].key));
      });
    });
    test('undo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      frameData.addFrame();
      frameData.addFrame();
      frameData.addFrame();
      expect(states.length, equals(3));
      frameData.addFrame(beforeFrame: frameData.state.frames[2].key);
      expect(states.length, equals(4));
      expect(frameData.state.frames.length, equals(5));
      expect(states[2].frames[0].key, equals(frameData.state.frames[0].key));
      expect(states[2].frames[1].key, equals(frameData.state.frames[1].key));
      expect(states[2].frames[2].key,
          isNot(equals(frameData.state.frames[2].key)));
      expect(states[2].frames[2].key, equals(frameData.state.frames[3].key));
      expect(states[2].frames[3].key, equals(frameData.state.frames[4].key));
      frameData.undo();
      expect(states.length, equals(5));
      expect(frameData.state.frames.length, equals(4));
      expect(frameData.state.frameKeys, equals(states[2].frameKeys));
    });
    test('redo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      frameData.addFrame();
      frameData.addFrame();
      frameData.addFrame();
      expect(states.length, equals(3));
      frameData.addFrame(beforeFrame: frameData.state.frames[2].key);
      expect(states.length, equals(4));
      expect(frameData.state.frames.length, equals(5));
      expect(states[2].frames[0].key, equals(frameData.state.frames[0].key));
      expect(states[2].frames[1].key, equals(frameData.state.frames[1].key));
      expect(states[2].frames[2].key,
          isNot(equals(frameData.state.frames[2].key)));
      expect(states[2].frames[2].key, equals(frameData.state.frames[3].key));
      expect(states[2].frames[3].key, equals(frameData.state.frames[4].key));
      frameData.undo();
      expect(states.length, equals(5));
      expect(frameData.state.frames.length, equals(4));
      expect(frameData.state.frameKeys, equals(states[2].frameKeys));
      frameData.redo();
      expect(states.length, equals(6));
      expect(frameData.state.frames.length, equals(5));
      expect(states[2].frames[0].key, equals(frameData.state.frames[0].key));
      expect(states[2].frames[1].key, equals(frameData.state.frames[1].key));
      expect(states[2].frames[2].key,
          isNot(equals(frameData.state.frames[2].key)));
      expect(states[2].frames[2].key, equals(frameData.state.frames[3].key));
      expect(states[2].frames[3].key, equals(frameData.state.frames[4].key));
    });
  });

  group('FrameData.deleteFrame', () {
    group('exec', () {
      test('deletes first frame', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        final expectedKeysAfterDelete = frameData.state.frameKeys.sublist(1);
        frameData.deleteFrame(frameData.state.frames.first.key);
        expect(states.length, equals(3));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(expectedKeysAfterDelete));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.first));
      });
      test('deletes middle frame', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        final frameKeys = frameData.state.frameKeys;
        frameData.deleteFrame(frameKeys.removeAt(1));
        expect(states.length, equals(3));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(frameKeys));
        expect(frameData.state.currentFrame, equals(frameData.state.frames[1]));
      });
      test('deletes last frame', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        frameData.deleteFrame(frameData.state.frames.last.key);
        expect(states.length, equals(5));
        expect(frameData.state.frames.length, equals(4));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.last));
      });
    });
    group('undo', () {
      test('deleting first frame', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        final expectedFrameKeysAfterDelete =
            frameData.state.frameKeys.sublist(1);
        final removed = frameData.state.frames.first;
        frameData.deleteFrame(removed.key);
        expect(states.length, equals(3));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(expectedFrameKeysAfterDelete));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.first));
        frameData.undo();
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(3));
        expect(frameData.state.frames.first, equals(removed));
        expect(frameData.state.currentFrame, equals(removed));
      });
      test('deleting middle frame', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        final frameKeys = frameData.state.frameKeys;
        final removeFrameKey = frameKeys.removeAt(1);
        final removed = frameData.state.frames[1];
        frameData.deleteFrame(removeFrameKey);
        expect(states.length, equals(3));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(frameKeys));
        expect(frameData.state.currentFrame, equals(frameData.state.frames[1]));
        frameData.undo();
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(3));
        expect(frameData.state.frames[1], equals(removed));
        expect(frameData.state.currentFrame.key, equals(removeFrameKey));
      });
      test('deleting last frame', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        final expectedFrameKeysAfterUndo = frameData.state.frameKeys;
        final expectedFrameKeysAfterDelete = expectedFrameKeysAfterUndo
            .where((frameKey) => frameKey != expectedFrameKeysAfterUndo.last);
        final removed = frameData.state.frames.last;
        frameData.deleteFrame(removed.key);
        expect(states.length, equals(3));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(expectedFrameKeysAfterDelete));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.last));
        frameData.undo();
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(3));
        expect(frameData.state.frameKeys, equals(expectedFrameKeysAfterUndo));
        expect(frameData.state.frames.last, equals(removed));
        expect(frameData.state.currentFrame, equals(removed));
      });
    });
    group('redo', () {
      test('deleting first frame', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        final expectedFrameKeysAfterDelete =
            frameData.state.frameKeys.sublist(1);
        final removed = frameData.state.frames.first;
        frameData.deleteFrame(removed.key);
        expect(states.length, equals(3));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(expectedFrameKeysAfterDelete));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.first));
        frameData.undo();
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(3));
        expect(frameData.state.frames.first, equals(removed));
        expect(frameData.state.currentFrame, equals(removed));
        frameData.redo();
        expect(states.length, equals(5));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(expectedFrameKeysAfterDelete));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.first));
      });
      test('deleting middle frame', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        final frameKeys = frameData.state.frameKeys;
        final removeFrameKey = frameKeys.removeAt(1);
        final removed = frameData.state.frames[1];
        frameData.deleteFrame(removeFrameKey);
        expect(states.length, equals(3));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(frameKeys));
        expect(frameData.state.currentFrame, equals(frameData.state.frames[1]));
        frameData.undo();
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(3));
        expect(frameData.state.frames[1], equals(removed));
        expect(frameData.state.currentFrame.key, equals(removeFrameKey));
        frameData.redo();
        expect(states.length, equals(5));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(frameKeys));
        expect(frameData.state.currentFrame, equals(frameData.state.frames[1]));
      });
      test('deleting last frame', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        final expectedFrameKeysAfterUndo = frameData.state.frameKeys;
        final expectedFrameKeysAfterDelete = expectedFrameKeysAfterUndo
            .where((frameKey) => frameKey != expectedFrameKeysAfterUndo.last);
        final removed = frameData.state.frames.last;
        frameData.deleteFrame(removed.key);
        expect(states.length, equals(3));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(expectedFrameKeysAfterDelete));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.last));
        frameData.undo();
        expect(states.length, equals(4));
        expect(frameData.state.frames.length, equals(3));
        expect(frameData.state.frameKeys, equals(expectedFrameKeysAfterUndo));
        expect(frameData.state.frames.last, equals(removed));
        expect(frameData.state.currentFrame, equals(removed));
        frameData.redo();
        expect(states.length, equals(5));
        expect(frameData.state.frames.length, equals(2));
        expect(frameData.state.frameKeys, equals(expectedFrameKeysAfterDelete));
        expect(
            frameData.state.currentFrame, equals(frameData.state.frames.last));
      });
    });
  });

  group('FrameData.reorderFrame', () {
    group('beforeFrame', () {
      test('exec', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        final expectedKeys = [
          frameData.state.frames[1].key,
          frameData.state.frames[0].key,
          frameData.state.frames[2].key,
          frameData.state.frames[3].key
        ];
        final reorderFrameKey = frameData.state.frames[1].key;
        frameData.reorderFrame(reorderFrameKey,
            beforeFrame: frameData.state.frames[0].key);
        expect(states.length, equals(4));
        expect(expectedKeys, equals(frameData.state.frameKeys));
        expect(frameData.state.currentFrame.key, equals(reorderFrameKey));
      });
      test('undo', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        final originalKeys = frameData.state.frameKeys;
        final expectedKeys = [
          frameData.state.frames[1].key,
          frameData.state.frames[0].key,
          frameData.state.frames[2].key,
          frameData.state.frames[3].key
        ];
        final reorderFrameKey = frameData.state.frames[1].key;
        frameData.reorderFrame(reorderFrameKey,
            beforeFrame: frameData.state.frames[0].key);
        expect(states.length, equals(4));
        expect(expectedKeys, equals(frameData.state.frameKeys));
        frameData.undo();
        expect(states.length, equals(5));
        expect(originalKeys, equals(frameData.state.frameKeys));
        expect(frameData.state.currentFrame.key, equals(reorderFrameKey));
      });
      test('redo', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        final originalKeys = frameData.state.frameKeys;
        final expectedKeys = [
          frameData.state.frames[1].key,
          frameData.state.frames[0].key,
          frameData.state.frames[2].key,
          frameData.state.frames[3].key
        ];
        final reorderFrameKey = frameData.state.frames[1].key;
        frameData.reorderFrame(reorderFrameKey,
            beforeFrame: frameData.state.frames[0].key);
        expect(states.length, equals(4));
        expect(expectedKeys, equals(frameData.state.frameKeys));
        frameData.undo();
        expect(states.length, equals(5));
        expect(originalKeys, equals(frameData.state.frameKeys));
        expect(frameData.state.currentFrame.key, equals(reorderFrameKey));
        frameData.redo();
        expect(states.length, equals(6));
        expect(expectedKeys, equals(frameData.state.frameKeys));
      });
    });

    group('afterFrame', () {
      test('exec', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        final expectedKeys = [
          frameData.state.frames[0].key,
          frameData.state.frames[2].key,
          frameData.state.frames[1].key,
          frameData.state.frames[3].key
        ];
        frameData.reorderFrame(frameData.state.frames[1].key,
            afterFrame: frameData.state.frames[2].key);
        expect(states.length, equals(4));
        expect(expectedKeys, equals(frameData.state.frameKeys));
      });
      test('undo', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        final originalKeys = frameData.state.frameKeys;
        final expectedKeys = [
          frameData.state.frames[0].key,
          frameData.state.frames[2].key,
          frameData.state.frames[1].key,
          frameData.state.frames[3].key
        ];
        frameData.reorderFrame(frameData.state.frames[1].key,
            afterFrame: frameData.state.frames[2].key);
        expect(states.length, equals(4));
        expect(expectedKeys, equals(frameData.state.frameKeys));
        frameData.undo();
        expect(states.length, equals(5));
        expect(originalKeys, equals(frameData.state.frameKeys));
      });
      test('redo', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        final originalKeys = frameData.state.frameKeys;
        final expectedKeys = [
          frameData.state.frames[0].key,
          frameData.state.frames[2].key,
          frameData.state.frames[1].key,
          frameData.state.frames[3].key
        ];
        frameData.reorderFrame(frameData.state.frames[1].key,
            afterFrame: frameData.state.frames[2].key);
        expect(states.length, equals(4));
        expect(expectedKeys, equals(frameData.state.frameKeys));
        frameData.undo();
        expect(states.length, equals(5));
        expect(originalKeys, equals(frameData.state.frameKeys));
        frameData.redo();
        expect(states.length, equals(6));
        expect(expectedKeys, equals(frameData.state.frameKeys));
      });
    });
  });

  group('FrameData.addEntity', () {
    test('exec', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      expect(states.length, equals(1));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(frameData.state.currentFrame.entities[0], equals(entity));
    });
    test('undo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      expect(states.length, equals(1));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(frameData.state.currentFrame.entities[0], equals(entity));
      frameData.undo();
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.isEmpty, equals(true));
    });
    test('redo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      expect(states.length, equals(1));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(frameData.state.currentFrame.entities[0], equals(entity));
      frameData.undo();
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.isEmpty, equals(true));
      frameData.redo();
      expect(states.length, equals(3));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(frameData.state.currentFrame.entities[0], equals(entity));
    });
  });

  group('FrameData.moveEntity', () {
    test('exec', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      frameData.moveEntity(entity, const Offset(10, 10));
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(frameData.state.currentFrame.entities[0],
          equals(entity.mutate(offset: const Offset(10, 10))));
    });
    test('undo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      frameData.moveEntity(entity, const Offset(10, 10));
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(frameData.state.currentFrame.entities[0],
          equals(entity.mutate(offset: const Offset(10, 10))));
      frameData.undo();
      expect(states.length, equals(3));
      expect(frameData.state.currentFrame.entities[0], equals(entity));
    });
    test('redo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      expect(states.length, equals(1));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(frameData.state.currentFrame.entities[0], equals(entity));
      frameData.undo();
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.isEmpty, equals(true));
      frameData.redo();
      expect(states.length, equals(3));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(frameData.state.currentFrame.entities[0], equals(entity));
    });
  });

  group('FrameData.resizeEntity', () {
    test('exec', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      frameData.resizeEntity(entity, const Offset(10, 10), const Size(40, 40));
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(
          frameData.state.currentFrame.entities[0],
          equals(entity.mutate(
              offset: const Offset(10, 10), size: const Size(40, 40))));
    });
    test('undo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      frameData.resizeEntity(entity, const Offset(10, 10), const Size(40, 40));
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(
          frameData.state.currentFrame.entities[0],
          equals(entity.mutate(
              offset: const Offset(10, 10), size: const Size(40, 40))));
      frameData.undo();
      expect(states.length, equals(3));
      expect(frameData.state.currentFrame.entities[0],
          equals(entity.mutate(offset: const Offset(10, 10))));
    });
    test('redo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      frameData.resizeEntity(entity, const Offset(10, 10), const Size(40, 40));
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(
          frameData.state.currentFrame.entities[0],
          equals(entity.mutate(
              offset: const Offset(10, 10), size: const Size(40, 40))));
      frameData.undo();
      expect(states.length, equals(3));
      expect(frameData.state.currentFrame.entities[0],
          equals(entity.mutate(offset: const Offset(10, 10))));
      frameData.redo();
      expect(states.length, equals(4));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expect(
          frameData.state.currentFrame.entities[0],
          equals(entity.mutate(
              offset: const Offset(10, 10), size: const Size(40, 40))));
    });
  });

  group('FrameData.deleteEntity', () {
    test('exec', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      expect(frameData.state.currentFrame.entities.isNotEmpty, equals(true));
      frameData.deleteEntity(entity.key);
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.isEmpty, equals(true));
    });
    test('undo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      expect(frameData.state.currentFrame.entities.isNotEmpty, equals(true));
      frameData.deleteEntity(entity.key);
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.isEmpty, equals(true));
      frameData.undo();
      expect(states.length, equals(3));
      expect(frameData.state.currentFrame.entities.isNotEmpty, equals(true));
      expect(frameData.state.currentFrame.entities[0], equals(entity));
    });
    test('redo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      expect(frameData.state.currentFrame.entities.isNotEmpty, equals(true));
      frameData.deleteEntity(entity.key);
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.isEmpty, equals(true));
      frameData.undo();
      expect(states.length, equals(3));
      expect(frameData.state.currentFrame.entities.isNotEmpty, equals(true));
      expect(frameData.state.currentFrame.entities[0], equals(entity));
      frameData.redo();
      expect(states.length, equals(4));
      expect(frameData.state.currentFrame.entities.isEmpty, equals(true));
    });
  });
}
