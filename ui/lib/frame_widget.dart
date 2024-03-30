import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_ui/editor_data.dart';

import 'frame_data.dart';

enum EntityInteractionMode {
  unclickable,
  clickable,
  selected,
  moving,
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

  bool isMovable() {
    return isMoving() || isClickable();
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
  Offset panning = Offset.zero;
  late final StreamSubscription editorInteractionSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub =
        EditorData.interactionState.listen((editorInteraction) => setState(() {
              if (editorInteraction?.movingEntity?.entityKey ==
                  widget.entity.key) {
                mode = EntityInteractionMode.moving;
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
    return Positioned(
        left: widget.entity.x - FrameEntityWidget.borderWidth + panning.dx,
        top: widget.entity.y - FrameEntityWidget.borderWidth + panning.dy,
        child: MouseRegion(
          cursor: cursor,
          onHover: onCursorHover,
          onExit: onCursorExit,
          child: GestureDetector(
            onPanStart: mode.isMovable() ? onPanStart : null,
            onPanUpdate: mode.isMovable() ? onPanUpdate : null,
            onPanEnd: mode.isMovable() ? onPanEnd : null,
            onTap: mode.isClickable() ? onTap : null,
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
    if (mode.isMoving()) {
      return Colors.orange;
    } else if (mode.isSelected()) {
      return Colors.green;
    } else {
      return Colors.transparent;
    }
  }

  onCursorHover(PointerHoverEvent event) {
    MouseCursor? change =
        switch (isEdgePosition(event.localPosition, widget.entity.size)) {
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
    EditorData.startMoveEntityInteraction(widget.entity);
  }

  onPanUpdate(DragUpdateDetails details) {
    if (mode.isMoving()) {
      setState(() => panning += details.delta);
    }
  }

  onPanEnd(DragEndDetails details) {
    FrameData.moveEntity(widget.entity, panning);
    EditorData.selectEntityInteraction(widget.entity);
    setState(() => panning = Offset.zero);
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

enum WidgetEdge {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

WidgetEdge? isEdgePosition(Offset offset, Size size) {
  final top = isTopEdge(offset);
  final left = isLeftEdge(offset);
  final bottom = isBottomEdge(offset, size);
  final right = isRightEdge(offset, size);
  if (top) {
    if (left) {
      return WidgetEdge.topLeft;
    } else if (right) {
      return WidgetEdge.topRight;
    } else {
      return WidgetEdge.top;
    }
  } else if (bottom) {
    if (left) {
      return WidgetEdge.bottomLeft;
    } else if (right) {
      return WidgetEdge.bottomRight;
    } else {
      return WidgetEdge.bottom;
    }
  } else if (left) {
    return WidgetEdge.left;
  } else if (right) {
    return WidgetEdge.right;
  } else {
    return null;
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
