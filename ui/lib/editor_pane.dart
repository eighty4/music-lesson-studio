import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_ui/editor_data.dart';
import 'package:mls_ui/frame_data.dart';
import 'package:mls_ui/frame_widget.dart';

// todo _EditorPaneState show entities
// todo _EditorPaneState add entity
// todo _EditorPaneState move entity
// todo _EditorPaneState resize entity

class EditorPane extends StatefulWidget {
  const EditorPane({super.key});

  @override
  State<EditorPane> createState() => _EditorPaneState();
}

class _EditorPaneState extends State<EditorPane> {
  Offset cursorPosition = Offset.zero;
  bool hovering = false;
  Frame frame = Frame();
  EditorInteraction? editorInteraction;
  TabContext tabContext = TabContext.forBrightness(Brightness.dark);
  late final StreamSubscription editorInteractionStateSub;
  late final StreamSubscription frameDataSub;

  @override
  void initState() {
    super.initState();
    editorInteractionStateSub = EditorData.interactionState.listen(
        (editorInteraction) =>
            setState(() => this.editorInteraction = editorInteraction));
    frameDataSub = FrameData.currentFrame
        .listen((frame) => setState(() => this.frame = frame));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
            onEnter: (e) => setState(() => hovering = true),
            onExit: (e) => setState(() => hovering = false),
            onHover: (event) =>
                setState(() => cursorPosition = event.localPosition),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ...frame.entities.map((entity) => FrameEntityWidget(
                      entity,
                      tabContext: tabContext,
                    )),
                if (hovering && editorInteraction != null)
                  buildEditorInteraction(),
              ],
            )),
      ),
    );
  }

  Widget buildEditorInteraction() {
    if (editorInteraction?.addingEntity != null) {
      final entityType = editorInteraction!.addingEntity!.entityType;
      final content = switch (entityType) {
        EntityType.chordChart => ChordChartDisplay(
            chord: ChordNoteSet(Instrument.banjo, Chord.c),
            tabContext: tabContext,
            size: ChordChartDisplay.defaultSize),
        EntityType.measureChart => MeasureDisplay(
            Measure.fromNoteList([
              Note(2, 1),
              Note(5, 0),
              Note(1, 2),
              Note(5, 0),
              Note(1, 0),
              null,
              Note(5, 0),
              Note(1, 0),
            ]),
            instrument: Instrument.banjo,
            tabContext: tabContext,
            size: MeasureDisplay.defaultSize),
        EntityType.paragraphText => throw UnimplementedError(),
        EntityType.hypermediaLink => throw UnimplementedError(),
        EntityType.imageUpload => throw UnimplementedError(),
        EntityType.videoUpload => throw UnimplementedError(),
        EntityType.videoRecord => throw UnimplementedError(),
        EntityType.youTubeEmbed => throw UnimplementedError(),
      };
      return Positioned(
          left: cursorPosition.dx, top: cursorPosition.dy, child: content);
    } else {
      return Container();
    }
  }

  onTap() {
    if (editorInteraction?.addingEntity != null) {
      EditorData.clearCurrentInteraction();
      final size = switch (editorInteraction!.addingEntity!.entityType) {
        EntityType.chordChart => ChordChartDisplay.defaultSize,
        EntityType.measureChart => MeasureDisplay.defaultSize,
        _ => const Size(100, 100),
      };
      FrameData.addEntity(Entity(
        type: editorInteraction!.addingEntity!.entityType,
        x: cursorPosition.dx,
        y: cursorPosition.dy,
        size: size,
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    frameDataSub.cancel();
    editorInteractionStateSub.cancel();
  }
}
