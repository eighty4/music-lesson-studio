import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libtab/libtab.dart';
import 'package:meta/meta.dart';
import 'package:mls_api/api_types.dart';
import 'package:mls_studio/cursor_override.dart';
import 'package:mls_studio/editor_pane.dart';
import 'package:mls_studio/frame_data.dart';
import 'package:mls_studio/frame_scaling.dart';
import 'package:mls_studio/frame_widget.dart';

typedef EditorPaneTestFunction =
    Future<void> Function(
      FrameData frameData,
      FrameScaling frameScaling,
      Future<void> Function() rebuild,
      List<FrameDataState> states,
      WidgetTester tester,
    );

@isTest
void testEditorPane(
  String description, {
  String? goldPath,
  required Size testSize,
  required EditorPaneTestFunction test,
}) {
  testWidgets(description, (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(testSize);
    final frameScaling = FrameScaling(
      frameOffset: Offset.zero,
      frameSize: testSize,
    );
    List<FrameDataState> states = [];
    final frameData = FrameData(onFrameDataChange: states.add);

    rebuild() async {
      await buildEditorPane(
        tester,
        frameData: frameData,
        frameScaling: frameScaling,
        testSize: testSize,
      );
    }

    await test(frameData, frameScaling, rebuild, states, tester);

    if (goldPath != null) {
      await rebuild();
      await expectLater(
        find.byType(EditorPane),
        matchesGoldenFile(goldPath),
        skip: !Platform.isMacOS,
      );
    }
  });
}

Future<void> buildEditorPane(
  WidgetTester tester, {
  required FrameData frameData,
  required FrameScaling frameScaling,
  required Size testSize,
}) async {
  await tester.pumpWidget(
    InheritedCursorOverride(
      onCursorOverride: (_) {},
      child: InheritedFrameData(
        frameData: frameData,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: EditorPane(
            currentFrame: frameData.state.currentFrame,
            frameScaling: frameScaling,
            tabContext: TabContext.forBrightness(Brightness.dark),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testEditorPane(
    'Select frame entity widget',
    goldPath: 'gold/frame_widget/select_entity.png',
    testSize: const Size(100, 100),
    test: (frameData, frameScaling, rebuild, states, tester) async {
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(.2, .2),
        size: const Size(.4, .4),
      );
      frameData.addEntity(entity);
      await rebuild();

      await tester.tap(find.byType(FrameEntityWidget));

      expect(states.length, equals(1));
      expect(states[0], equals(frameData.state));
      expect(frameData.state.currentFrame.entities[0], entity);
    },
  );

  testEditorPane(
    'Move frame entity widget',
    goldPath: 'gold/frame_widget/move_entity.png',
    testSize: const Size(100, 100),
    test: (frameData, frameScaling, rebuild, states, tester) async {
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(.2, .2),
        size: const Size(.4, .4),
      );
      frameData.addEntity(entity);
      await rebuild();

      await tester.dragFrom(
        entity.offset * 100 + const Offset(1, 1),
        const Offset(40, 40),
        kind: PointerDeviceKind.mouse,
      );

      expect(states.length, equals(2));
      expect(states[1], equals(frameData.state));
      expect(frameData.state.frames.length, equals(1));
      expect(
        frameData.state.currentFrame.entities[0],
        entity.mutate(offset: const Offset(.4, .4)),
      );
    },
  );

  testEditorPane(
    'Clamp move frame entity widget to canvas edge',
    goldPath: 'gold/frame_widget/move_entity_clamp.png',
    testSize: const Size(100, 100),
    test: (frameData, frameScaling, rebuild, states, tester) async {
      final entity = Entity.chordChart(
        chord: Chord.c,
        instrument: Instrument.banjo,
        offset: const Offset(.2, .2),
        size: const Size(.4, .4),
      );
      frameData.addEntity(entity);
      await rebuild();

      await tester.dragFrom(
        entity.offset * 100 + const Offset(1, 1),
        const Offset(100, 100),
        kind: PointerDeviceKind.mouse,
      );

      expect(states.length, equals(2));
      expect(states[1], equals(frameData.state));
      expect(frameData.state.frames.length, equals(1));
      expect(
        frameData.state.currentFrame.entities[0],
        entity.mutate(offset: const Offset(.6, .6)),
      );
    },
  );
}
