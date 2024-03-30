import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_ui/editor_data.dart';
import 'package:mls_ui/widget_edge.dart';

import 'frame_data.dart';

enum EntityInteractionMode {
  unclickable,
  clickable,
  selected,
  moving,
  resizing,
}

extension on EntityInteractionMode {
  bool isClickable() {
    return this != EntityInteractionMode.unclickable &&
        (this == EntityInteractionMode.clickable ||
            this == EntityInteractionMode.selected);
  }

  bool isSelected() {
    return this == EntityInteractionMode.selected;
  }

  bool isMoving() {
    return this == EntityInteractionMode.moving;
  }

  bool isResizing() {
    return this == EntityInteractionMode.resizing;
  }

  bool isMovableOrResizable() {
    return isClickable() || isMoving() || isResizing();
  }
}

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
  MouseCursor cursor = SystemMouseCursors.basic;
  EntityInteractionMode mode = EntityInteractionMode.clickable;
  Offset moving = Offset.zero;
  Offset resizing = Offset.zero;
  WidgetEdge? resizingEdge;
  late final StreamSubscription editorInteractionSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub =
        EditorData.interactionState.listen((editorInteraction) => setState(() {
              if (editorInteraction?.movingEntity?.entityKey ==
                  widget.entity.key) {
                mode = EntityInteractionMode.moving;
              } else if (editorInteraction?.resizingEntity?.entityKey ==
                  widget.entity.key) {
                mode = EntityInteractionMode.resizing;
              } else if (editorInteraction?.selectedEntity?.entityKey ==
                  widget.entity.key) {
                mode = EntityInteractionMode.selected;
              } else if (editorInteraction?.addingEntity != null) {
                mode = EntityInteractionMode.unclickable;
              } else {
                mode = EntityInteractionMode.clickable;
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    final (offset, size) = switch (mode) {
      EntityInteractionMode.resizing => calculateResize(
          resizingEdge,
          Offset(widget.entity.x, widget.entity.y),
          widget.entity.size,
          resizing),
      EntityInteractionMode.moving => (
          Offset(widget.entity.x + moving.dx, widget.entity.y + moving.dy),
          widget.entity.size
        ),
      _ => (Offset(widget.entity.x, widget.entity.y), widget.entity.size)
    };
    return Positioned(
        left: offset.dx - FrameEntityWidget.borderWidth,
        top: offset.dy - FrameEntityWidget.borderWidth,
        child: MouseRegion(
          cursor: cursor,
          onHover: onCursorHover,
          onExit: onCursorExit,
          child: GestureDetector(
            onPanStart: mode.isMovableOrResizable() ? onPanStart : null,
            onPanUpdate: mode.isMovableOrResizable() ? onPanUpdate : null,
            onPanEnd: mode.isMovableOrResizable() ? onPanEnd : null,
            onTap: mode.isClickable() ? onTap : null,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: resolveBorderColor(),
                      width: FrameEntityWidget.borderWidth)),
              child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: buildContent(size)),
            ),
          ),
        ));
  }

  Widget buildContent(Size size) {
    return switch (widget.entity.type) {
      EntityType.chordChart => ChordChartDisplay(
          chord: ChordNoteSet(Instrument.banjo, Chord.c),
          tabContext: widget.tabContext,
          size: size),
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
          size: size),
      EntityType.paragraphText => throw UnimplementedError(),
      EntityType.hypermediaLink => throw UnimplementedError(),
      EntityType.imageUpload => throw UnimplementedError(),
      EntityType.videoUpload => throw UnimplementedError(),
      EntityType.videoRecord => throw UnimplementedError(),
      EntityType.youTubeEmbed => throw UnimplementedError(),
    };
  }

  Color resolveBorderColor() {
    if (mode.isMoving() || mode.isResizing()) {
      return Colors.orange;
    } else if (mode.isSelected()) {
      return Colors.green;
    } else {
      return Colors.transparent;
    }
  }

  onCursorHover(PointerHoverEvent event) {
    MouseCursor? change = switch (calculateEdgePosition(event.localPosition,
        widget.entity.size, FrameEntityWidget.resizeWidth)) {
      WidgetEdge.topLeft ||
      WidgetEdge.topRight ||
      WidgetEdge.bottomLeft ||
      WidgetEdge.bottomRight =>
        SystemMouseCursors.precise,
      WidgetEdge.top || WidgetEdge.bottom => SystemMouseCursors.resizeRow,
      WidgetEdge.left || WidgetEdge.right => SystemMouseCursors.resizeColumn,
      null => SystemMouseCursors.basic,
    };
    if (change != cursor) {
      setState(() => cursor = change);
    }
  }

  onCursorExit(PointerExitEvent event) {
    setState(() => cursor = SystemMouseCursors.basic);
  }

  onPanStart(DragStartDetails details) {
    final edge = calculateEdgePosition(details.localPosition,
        widget.entity.size, FrameEntityWidget.resizeWidth);
    if (edge != null) {
      resizingEdge = edge;
      EditorData.startResizeEntityInteraction(widget.entity);
    } else {
      EditorData.startMoveEntityInteraction(widget.entity);
    }
  }

  onPanUpdate(DragUpdateDetails details) {
    if (mode.isMoving()) {
      setState(() => moving += details.delta);
    } else if (mode.isResizing()) {
      setState(() => resizing += details.delta);
    }
  }

  onPanEnd(DragEndDetails details) {
    if (mode.isMoving()) {
      FrameData.moveEntity(widget.entity, moving);
    } else if (mode.isResizing()) {
      FrameData.resizeEntity(widget.entity, resizingEdge!, resizing);
    }
    EditorData.selectEntityInteraction(widget.entity);
    setState(() {
      moving = Offset.zero;
      resizing = Offset.zero;
    });
  }

  onTap() {
    if (!mode.isMoving()) {
      EditorData.selectEntityInteraction(widget.entity);
    }
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
  }
}
