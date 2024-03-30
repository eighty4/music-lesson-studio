import 'dart:async';

import 'package:flutter/material.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_ui/editor_data.dart';

import 'frame_data.dart';

class FrameEntityWidget extends StatefulWidget {
  static const double borderWidth = 3;
  final Entity entity;
  final TabContext tabContext;

  const FrameEntityWidget(this.entity, {super.key, required this.tabContext});

  @override
  State<StatefulWidget> createState() {
    return _FrameEntityWidgetState();
  }
}

class _FrameEntityWidgetState extends State<FrameEntityWidget> {
  bool clickable = true;
  bool selected = false;
  late final StreamSubscription editorInteractionSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub =
        EditorData.interactionState.listen((editorInteraction) => setState(() {
              clickable = editorInteraction?.addingEntity == null;
              selected = editorInteraction?.selectedEntity?.entityKey ==
                  widget.entity.key;
            }));
  }

  @override
  Widget build(BuildContext context) {
    final content = switch (widget.entity.type) {
      EntityType.chordChart => ChordChartDisplay(
          chord: ChordNoteSet(Instrument.banjo, Chord.c),
          tabContext: widget.tabContext,
          size: widget.entity.size),
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
          tabContext: widget.tabContext,
          size: widget.entity.size),
      EntityType.paragraphText => throw UnimplementedError(),
      EntityType.hypermediaLink => throw UnimplementedError(),
      EntityType.imageUpload => throw UnimplementedError(),
      EntityType.videoUpload => throw UnimplementedError(),
      EntityType.videoRecord => throw UnimplementedError(),
      EntityType.youTubeEmbed => throw UnimplementedError(),
    };
    return Positioned(
        left: widget.entity.x - FrameEntityWidget.borderWidth,
        top: widget.entity.y - FrameEntityWidget.borderWidth,
        child: GestureDetector(
          onTap: clickable ? onTap : null,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: selected ? Colors.green : Colors.transparent,
                    width: FrameEntityWidget.borderWidth)),
            child: SizedBox(
                width: widget.entity.size.width,
                height: widget.entity.size.height,
                child: content),
          ),
        ));
  }

  onTap() {
    EditorData.selectEntityInteraction(widget.entity);
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
  }
}
