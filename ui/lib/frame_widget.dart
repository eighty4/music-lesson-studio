import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';

import 'editor_data.dart';
import 'editor_shortcuts.dart';
import 'entity_content.dart';
import 'entity_data.dart';
import 'entity_edge.dart';
import 'frame_data.dart';
import 'frame_menu.dart';
import 'frame_scaling.dart';

enum EntityMenuOption { copy, paste, delete }

final entityMenuOptions =
    EntityMenuOption.values.map((v) => FrameMenuOption(v.name, v)).toList();

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

  bool isCancelable() {
    return isMoving() || isResizing();
  }
}

class FrameEntityWidget extends StatefulWidget {
  static const double borderWidth = 3;
  static const double resizeWidth = 7;
  final Entity entity;
  final FrameScaling scaling;
  final TabContext tabContext;

  const FrameEntityWidget(this.entity,
      {super.key, required this.scaling, required this.tabContext});

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
  EntityEdge resizingEdge = EntityEdge.bottomRight;
  late final StreamSubscription editorInteractionSub;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(debugLabel: "entity-${widget.entity.type.name}");
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
              if (mode.isSelected() || mode.isCancelable()) {
                FocusScope.of(context).requestFocus(focusNode);
              } else {
                focusNode.unfocus(
                    disposition: UnfocusDisposition.previouslyFocusedChild);
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    final (offset, size) = calculateEntityDimensions();
    return Positioned(
      left: offset.dx - FrameEntityWidget.borderWidth,
      top: offset.dy - FrameEntityWidget.borderWidth,
      child: FrameMenu<EntityMenuOption>(
          callback: onMenuOption,
          disabled: const [EntityMenuOption.copy, EntityMenuOption.paste],
          options: entityMenuOptions,
          predicate: (editorInteraction) =>
              editorInteraction.openEntityMenu?.entityKey == widget.entity.key,
          child: buildEntity(size)),
    );
  }

  Widget buildEntity(Size size) {
    return Actions(
      actions: <Type, Action<Intent>>{
        if (mode.isCancelable())
          CancelIntent: CancelAction(entityKey: widget.entity.key),
        if (!mode.isCancelable() && mode == EntityInteractionMode.selected)
          CancelIntent: CancelAction(),
        if (mode == EntityInteractionMode.selected)
          DeleteIntent: DeleteAction(widget.entity.key),
      },
      child: Focus(
        focusNode: focusNode,
        child: MouseRegion(
            cursor: cursor,
            onHover: onCursorHover,
            onExit: onCursorExit,
            child: GestureDetector(
                onPanStart: mode.isMovableOrResizable() ? onPanStart : null,
                onPanUpdate: mode.isMovableOrResizable() ? onPanUpdate : null,
                onPanEnd: mode.isMovableOrResizable() ? onPanEnd : null,
                onTap: mode.isClickable() ? onLeftClick : null,
                onSecondaryTap: onRightClick,
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: resolveBorderColor(),
                            width: FrameEntityWidget.borderWidth)),
                    child: SizedBox(
                        width: size.width,
                        height: size.height,
                        child: EntityContent(widget.entity,
                            size: size, tabContext: widget.tabContext))))),
      ),
    );
  }

  // todo scale for aspect ratio
  (Offset, Size) calculateEntityDimensions() {
    return switch (mode) {
      EntityInteractionMode.moving => (
          widget.scaling.clampEntityMove(widget.entity, moving),
          widget.entity.size,
        ),
      EntityInteractionMode.resizing =>
        widget.scaling.clampEntityResize(widget.entity, resizingEdge, resizing),
      _ => (widget.entity.offset, widget.entity.size),
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
      EntityEdge.topLeft ||
      EntityEdge.topRight ||
      EntityEdge.bottomLeft ||
      EntityEdge.bottomRight =>
        SystemMouseCursors.precise,
      EntityEdge.top || EntityEdge.bottom => SystemMouseCursors.resizeRow,
      EntityEdge.left || EntityEdge.right => SystemMouseCursors.resizeColumn,
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
    // todo scale for aspect ratio
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
      // todo scale for aspect ratio
      setState(() => moving += details.delta);
    } else if (mode.isResizing()) {
      // todo scale for aspect ratio
      setState(() => resizing += details.delta);
    }
  }

  onPanEnd(DragEndDetails details) {
    if (mode.isMoving()) {
      // todo scale for aspect ratio
      FrameData.moveEntity(widget.entity, widget.scaling, moving);
    } else if (mode.isResizing()) {
      // todo scale for aspect ratio
      FrameData.resizeEntity(
          widget.entity, widget.scaling, resizingEdge, resizing);
    }
    EditorData.selectEntityInteraction(widget.entity.key);
    setState(() {
      moving = Offset.zero;
      resizing = Offset.zero;
    });
  }

  onLeftClick() {
    if (!mode.isMoving()) {
      EditorData.selectEntityInteraction(widget.entity.key);
    }
  }

  onRightClick() {
    EditorData.openEntityMenu(widget.entity.key);
  }

  void onMenuOption(EntityMenuOption option) {
    if (option == EntityMenuOption.delete) {
      FrameData.deleteEntity(widget.entity.key);
    } else if (kDebugMode) {
      print(option);
    }
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
    focusNode.dispose();
  }
}
