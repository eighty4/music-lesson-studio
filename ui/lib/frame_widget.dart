import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_ui/editor_data.dart';

import 'frame_data.dart';

class FrameEntityWidget extends StatefulWidget {
  static const double borderWidth = 3;
  static const double resizeWidth = 7;
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
  MouseCursor cursor = SystemMouseCursors.basic;
  Offset panning = Offset.zero;
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
    return Positioned(
        left: widget.entity.x - FrameEntityWidget.borderWidth + panning.dx,
        top: widget.entity.y - FrameEntityWidget.borderWidth + panning.dy,
        child: MouseRegion(
          cursor: cursor,
          onHover: onCursorHover,
          onExit: onCursorExit,
          child: GestureDetector(
            onPanStart: clickable ? onPanStart : null,
            onPanUpdate: clickable ? onPanUpdate : null,
            onPanEnd: clickable ? onPanEnd : null,
            onTap: clickable ? onTap : null,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: resolveBorderColor(),
                      width: FrameEntityWidget.borderWidth)),
              child: SizedBox(
                  width: widget.entity.size.width,
                  height: widget.entity.size.height,
                  child: buildContent()),
            ),
          ),
        ));
  }

  Widget buildContent() {
    return switch (widget.entity.type) {
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
  }

  Color resolveBorderColor() {
    if (panning != Offset.zero) {
      return Colors.orange;
    } else if (selected) {
      return Colors.green;
    } else {
      return Colors.transparent;
    }
  }

  onCursorHover(PointerHoverEvent event) {
    MouseCursor? change;
    final top = isTopEdge(event.localPosition);
    final left = isLeftEdge(event.localPosition);
    final bottom = isBottomEdge(event.localPosition, widget.entity.size);
    final right = isRightEdge(event.localPosition, widget.entity.size);
    if (top || bottom) {
      if (left || right) {
        change = SystemMouseCursors.precise;
      } else {
        change = SystemMouseCursors.resizeRow;
      }
    } else if (left || right) {
      change = SystemMouseCursors.resizeColumn;
    } else if (cursor != SystemMouseCursors.basic) {
      change = SystemMouseCursors.basic;
    }
    if (change != null) {
      setState(() => cursor = change!);
    }
  }

  onCursorExit(PointerExitEvent event) {
    setState(() => cursor = SystemMouseCursors.basic);
  }

  onPanStart(DragStartDetails details) {
    EditorData.startMoveEntityInteraction(widget.entity);
  }

  onPanUpdate(DragUpdateDetails details) {
    setState(() => panning += details.delta);
  }

  onPanEnd(DragEndDetails details) {
    FrameData.moveEntity(widget.entity, panning);
    EditorData.selectEntityInteraction(widget.entity);
    setState(() => panning = Offset.zero);
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

bool isTopEdge(Offset offset) {
  return offset.dy < FrameEntityWidget.resizeWidth;
}

bool isBottomEdge(Offset offset, Size size) {
  return offset.dy > size.height - FrameEntityWidget.resizeWidth;
}

bool isLeftEdge(Offset offset) {
  return offset.dx < FrameEntityWidget.resizeWidth;
}

bool isRightEdge(Offset offset, Size size) {
  return offset.dx > size.width - FrameEntityWidget.resizeWidth;
}
