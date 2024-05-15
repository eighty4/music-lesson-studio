import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mls_studio/api_types.dart';
import 'package:mls_studio/frame_data.dart';

import 'api_types_test.dart';

void main() {
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
        expect(frameData.state.frames.map((f) => f.key),
            equals(states[2].frames.map((f) => f.key)));
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
      expect(frameData.state.frames.map((f) => f.key),
          equals(states[2].frames.map((f) => f.key)));
    });
  });

  group('FrameData.deleteFrame', () {
    test('exec', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      frameData.addFrame();
      frameData.addFrame();
      final frameKeys =
          frameData.state.frames.map((frame) => frame.key).toList();
      final removeFrameKey = frameKeys.removeAt(1);
      frameData.deleteFrame(removeFrameKey);
      expect(states.length, equals(3));
      expect(frameData.state.frames.length, equals(2));
      expect(
          frameData.state.frames.map((frame) => frame.key), equals(frameKeys));
      expect(frameData.state.currentFrame, equals(frameData.state.frames[1]));
    });
    test('undo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      frameData.addFrame();
      frameData.addFrame();
      final frameKeys =
          frameData.state.frames.map((frame) => frame.key).toList();
      final removeFrameKey = frameKeys.removeAt(1);
      final removed = frameData.state.frames[1];
      frameData.deleteFrame(removeFrameKey);
      expect(states.length, equals(3));
      expect(frameData.state.frames.length, equals(2));
      expect(
          frameData.state.frames.map((frame) => frame.key), equals(frameKeys));
      expect(frameData.state.currentFrame, equals(frameData.state.frames[1]));
      frameData.undo();
      expect(states.length, equals(4));
      expect(frameData.state.frames.length, equals(3));
      expect(frameData.state.frames.last, equals(removed));
      expect(frameData.state.currentFrame.key, equals(removeFrameKey));
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
        expect(expectedKeys, equals(frameData.state.frames.map((f) => f.key)));
        expect(frameData.state.currentFrame.key, equals(reorderFrameKey));
      });
      test('undo', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        final originalKeys = frameData.state.frames.map((f) => f.key).toList();
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
        expect(expectedKeys, equals(frameData.state.frames.map((f) => f.key)));
        frameData.undo();
        expect(states.length, equals(5));
        expect(originalKeys, equals(frameData.state.frames.map((f) => f.key)));
        expect(frameData.state.currentFrame.key, equals(reorderFrameKey));
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
        expect(expectedKeys, equals(frameData.state.frames.map((f) => f.key)));
      });
      test('undo', () {
        final List<FrameDataState> states = [];
        final frameData = FrameData(onFrameDataChange: states.add);
        frameData.addFrame();
        frameData.addFrame();
        frameData.addFrame();
        expect(states.length, equals(3));
        final originalKeys = frameData.state.frames.map((f) => f.key).toList();
        final expectedKeys = [
          frameData.state.frames[0].key,
          frameData.state.frames[2].key,
          frameData.state.frames[1].key,
          frameData.state.frames[3].key
        ];
        frameData.reorderFrame(frameData.state.frames[1].key,
            afterFrame: frameData.state.frames[2].key);
        expect(states.length, equals(4));
        expect(expectedKeys, equals(frameData.state.frames.map((f) => f.key)));
        frameData.undo();
        expect(states.length, equals(5));
        expect(originalKeys, equals(frameData.state.frames.map((f) => f.key)));
      });
    });
  });

  group('FrameData.addEntity', () {
    test('exec', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity(
        type: EntityType.chordChart,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      expect(states.length, equals(1));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expectEntity(frameData.state.currentFrame.entities[0], entity);
    });
    test('undo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity(
        type: EntityType.chordChart,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      expect(states.length, equals(1));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expectEntity(frameData.state.currentFrame.entities[0], entity);
      frameData.undo();
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.isEmpty, equals(true));
    });
  });

  group('FrameData.moveEntity', () {
    test('exec', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity(
        type: EntityType.chordChart,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      frameData.moveEntity(entity, const Offset(10, 10));
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expectEntity(frameData.state.currentFrame.entities[0], entity,
          expectedOffset: const Offset(10, 10));
    });
    test('undo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity(
        type: EntityType.chordChart,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      frameData.moveEntity(entity, const Offset(10, 10));
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expectEntity(frameData.state.currentFrame.entities[0], entity,
          expectedOffset: const Offset(10, 10));
      frameData.undo();
      expect(states.length, equals(3));
      expectEntity(frameData.state.currentFrame.entities[0], entity);
    });
  });

  group('FrameData.resizeEntity', () {
    test('exec', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity(
        type: EntityType.chordChart,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      frameData.resizeEntity(entity, const Offset(10, 10), const Size(40, 40));
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expectEntity(frameData.state.currentFrame.entities[0], entity,
          expectedOffset: const Offset(10, 10),
          expectedSize: const Size(40, 40));
    });
    test('undo', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity(
        type: EntityType.chordChart,
        offset: const Offset(20, 20),
        size: const Size(30, 30),
      );
      frameData.addEntity(entity);
      frameData.resizeEntity(entity, const Offset(10, 10), const Size(40, 40));
      expect(states.length, equals(2));
      expect(frameData.state.currentFrame.entities.length, equals(1));
      expectEntity(frameData.state.currentFrame.entities[0], entity,
          expectedOffset: const Offset(10, 10),
          expectedSize: const Size(40, 40));
      frameData.undo();
      expect(states.length, equals(3));
      expectEntity(frameData.state.currentFrame.entities[0], entity);
    });
  });

  group('FrameData.deleteEntity', () {
    test('exec', () {
      final List<FrameDataState> states = [];
      final frameData = FrameData(onFrameDataChange: states.add);
      final entity = Entity(
        type: EntityType.chordChart,
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
      final entity = Entity(
        type: EntityType.chordChart,
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
      expectEntity(frameData.state.currentFrame.entities[0], entity);
    });
  });
}
