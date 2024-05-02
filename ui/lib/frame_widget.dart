import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';

import 'app_styles.dart';
import 'editor_data.dart';
import 'editor_shortcuts.dart';
import 'entity_content.dart';
import 'entity_data.dart';
import 'entity_edge.dart';
import 'frame_data.dart';
import 'frame_menu.dart';
import 'frame_scaling.dart';

class FrameEntityWidget extends StatelessWidget {
  final Entity entity;
  final bool interactive;
  final EntityProjection projection;
  final FrameScaling scaling;
  final TabContext tabContext;

  const FrameEntityWidget(this.entity,
      {super.key,
      this.interactive = true,
      required this.projection,
      required this.scaling,
      required this.tabContext});

  @override
  Widget build(BuildContext context) {
    return interactive
        ? _InteractiveFrameEntity(entity,
            projection: projection, scaling: scaling, tabContext: tabContext)
        : _NonInteractiveFrameEntity(entity,
            projection: projection, tabContext: tabContext);
  }
}

class _NonInteractiveFrameEntity extends StatelessWidget {
  final Entity entity;
  final EntityProjection projection;
  final TabContext tabContext;

  const _NonInteractiveFrameEntity(this.entity,
      {required this.tabContext, required this.projection});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: projection.offset.dx,
        top: projection.offset.dy,
        child: EntityContent(entity,
            tabContext: tabContext, size: projection.size));
  }
}

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

class _InteractiveFrameEntity extends StatefulWidget {
  static const double borderWidth = 3;
  static const double resizeWidth = 7;
  final Entity entity;
  final EntityProjection projection;
  final FrameScaling scaling;
  final TabContext tabContext;

  const _InteractiveFrameEntity(this.entity,
      {required this.projection,
      required this.scaling,
      required this.tabContext});

  @override
  State<StatefulWidget> createState() {
    return _InteractiveFrameEntityState();
  }
}

class _InteractiveFrameEntityState extends State<_InteractiveFrameEntity> {
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
    final projection = calculateEntityProjection();
    return Positioned(
      left: projection.offset.dx - _InteractiveFrameEntity.borderWidth,
      top: projection.offset.dy - _InteractiveFrameEntity.borderWidth,
      child: FrameMenu<EntityMenuOption>(
          callback: onMenuOption,
          disabled: const [EntityMenuOption.copy, EntityMenuOption.paste],
          options: entityMenuOptions,
          predicate: (editorInteraction) =>
              editorInteraction.openEntityMenu?.entityKey == widget.entity.key,
          child: buildEntity(projection)),
    );
  }

  Widget buildEntity(EntityProjection projection) {
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
                            width: _InteractiveFrameEntity.borderWidth)),
                    child: SizedBox(
                        width: projection.size.width,
                        height: projection.size.height,
                        child: EntityContent(widget.entity,
                            size: projection.size,
                            tabContext: widget.tabContext))))),
      ),
    );
  }

  EntityProjection calculateEntityProjection() {
    return switch (mode) {
      EntityInteractionMode.moving =>
        widget.scaling.clampEntityMove(widget.projection, moving),
      EntityInteractionMode.resizing => widget.scaling
          .clampEntityResize(widget.projection, resizingEdge, resizing),
      _ => widget.projection,
    };
  }

  Color resolveBorderColor() {
    if (mode.isMoving() || mode.isResizing()) {
      return AppStyles.frameEntityActiveBorderColor;
    } else if (mode.isSelected()) {
      return AppStyles.frameEntitySelectedBorderColor;
    } else {
      return AppStyles.transparentColor;
    }
  }

  onCursorHover(PointerHoverEvent event) {
    MouseCursor? change = switch (calculateEdgePosition(event.localPosition,
        widget.projection.size, _InteractiveFrameEntity.resizeWidth)) {
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
    final edge = calculateEdgePosition(details.localPosition,
        widget.projection.size, _InteractiveFrameEntity.resizeWidth);
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
      final movedProjection =
          widget.scaling.clampEntityMove(widget.projection, moving);
      FrameData.moveEntity(widget.entity.key,
          widget.scaling.reverseOffsetProjection(movedProjection));
    } else if (mode.isResizing()) {
      final resizedProjection = widget.scaling
          .clampEntityResize(widget.projection, resizingEdge, resizing);
      FrameData.resizeEntity(
          widget.entity.key,
          widget.scaling.reverseOffsetProjection(resizedProjection),
          widget.scaling.reverseSizeProjection(resizedProjection));
    }
    EditorData.selectEntityInteraction(widget.entity.key);
    setState(() {
      moving = Offset.zero;
      resizing = Offset.zero;
    });
  }

  onLeftClick() {
    if (kDebugMode) {
      print('_InteractiveFrameEntityState.onLeftClick');
    }
    if (!mode.isMoving()) {
      EditorData.selectEntityInteraction(widget.entity.key);
    }
  }

  onRightClick() {
    if (kDebugMode) {
      print('_InteractiveFrameEntityState.onLeftClick');
    }
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
