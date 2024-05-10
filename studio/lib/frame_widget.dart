import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:libtab/libtab.dart';

import 'api_types.dart';
import 'app_styles.dart';
import 'editor_data.dart';
import 'editor_shortcuts.dart';
import 'entity_content.dart';
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

enum _EntityMenuOption { copy, paste, delete }

final _entityMenuOptions =
    _EntityMenuOption.values.map((v) => FrameMenuOption(v.name, v)).toList();

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
  static const double _borderWidth = 3;
  static const double _resizeHitTestWidth = 5;
  static const double _resizeCursorSize = 20;
  static const Offset _resizeCursorOffset =
      Offset(_resizeCursorSize / 2, _resizeCursorSize / 2);
  static const String _resizeSvgAngle45 = 'assets/arrow_45.svg';
  static const String _resizeSvgAngle135 = 'assets/arrow_135.svg';
  static const String _resizeSvgHorizontal = 'assets/arrow_horizontal.svg';
  static const String _resizeSvgVertical = 'assets/arrow_vertical.svg';

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
  EntityInteractionMode mode = EntityInteractionMode.clickable;
  Offset moving = Offset.zero;
  Offset resizing = Offset.zero;
  String? resizeCursorSvg;
  Offset resizeStartPosition = Offset.zero;
  EntityEdge? resizeEdge;
  bool resizeTapDown = false;
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
      left: projection.offset.dx - _InteractiveFrameEntity._borderWidth,
      top: projection.offset.dy - _InteractiveFrameEntity._borderWidth,
      child: FrameMenu<_EntityMenuOption>(
          callback: onMenuOption,
          disabled: const [_EntityMenuOption.copy, _EntityMenuOption.paste],
          options: _entityMenuOptions,
          predicate: (interaction) =>
              interaction.openEntityMenu?.entityKey == widget.entity.key,
          child: buildEntity(projection)),
    );
  }

  Widget buildEntity(EntityProjection projection) {
    return Actions(
        actions: <Type, Action<Intent>>{
          if (mode.isCancelable())
            CancelIntent: CancelAction(entityKey: widget.entity.key),
          if (!mode.isCancelable() && mode.isSelected())
            CancelIntent: CancelAction(),
          if (mode.isSelected()) DeleteIntent: DeleteAction(widget.entity.key),
        },
        child: Focus(
            focusNode: focusNode,
            child: MouseRegion(
                cursor: mode.isResizing() || resizeCursorSvg != null
                    ? SystemMouseCursors.none
                    : SystemMouseCursors.basic,
                onHover: onCursorHover,
                onExit: onCursorExit,
                child: GestureDetector(
                    onTapDown: onTapDown,
                    onPanStart: mode.isMovableOrResizable() ? onPanStart : null,
                    onPanUpdate:
                        mode.isMovableOrResizable() ? onPanUpdate : null,
                    onPanEnd: mode.isMovableOrResizable() ? onPanEnd : null,
                    onTap: mode.isClickable() ? onLeftClick : null,
                    onSecondaryTap: onRightClick,
                    child: Stack(clipBehavior: Clip.none, children: [
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: resolveBorderColor(),
                                  width: _InteractiveFrameEntity._borderWidth)),
                          child: SizedBox(
                              width: projection.size.width,
                              height: projection.size.height,
                              child: EntityContent(widget.entity,
                                  size: projection.size,
                                  tabContext: widget.tabContext))),
                      if (resizeCursorSvg != null) buildResizeCursor()
                    ])))));
  }

  Positioned buildResizeCursor() {
    assert(resizeCursorSvg != null);
    assert(resizeEdge != null);
    late final double x;
    late final double y;
    if (resizeEdge!.isTop()) {
      y = resizeStartPosition.dy;
    } else {
      y = resizeStartPosition.dy + resizing.dy;
    }
    if (resizeEdge!.isLeft()) {
      x = resizeStartPosition.dx;
    } else {
      x = resizeStartPosition.dx + resizing.dx;
    }
    return Positioned(
        top: y,
        left: x,
        child: SvgPicture.asset(resizeCursorSvg!,
            height: _InteractiveFrameEntity._resizeCursorSize,
            width: _InteractiveFrameEntity._resizeCursorSize));
  }

  EntityProjection calculateEntityProjection() {
    return switch (mode) {
      EntityInteractionMode.moving =>
        widget.scaling.clampEntityMove(widget.projection, moving),
      EntityInteractionMode.resizing => widget.scaling
          .clampEntityResize(widget.projection, resizeEdge!, resizing),
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

  onTapDown(_) {
    if (resizeCursorSvg != null) {
      resizeTapDown = true;
    }
  }

  onCursorHover(PointerHoverEvent event) {
    assert(!mode.isResizing());
    final entityEdge = calculateEdgePosition(event.localPosition,
        widget.projection.size, _InteractiveFrameEntity._resizeHitTestWidth);
    String? resizeCursorSvg = switch (entityEdge) {
      EntityEdge.topLeft ||
      EntityEdge.bottomRight =>
        _InteractiveFrameEntity._resizeSvgAngle45,
      EntityEdge.bottomLeft ||
      EntityEdge.topRight =>
        _InteractiveFrameEntity._resizeSvgAngle135,
      EntityEdge.top ||
      EntityEdge.bottom =>
        _InteractiveFrameEntity._resizeSvgVertical,
      EntityEdge.left ||
      EntityEdge.right =>
        _InteractiveFrameEntity._resizeSvgHorizontal,
      null => null,
    };
    setState(() {
      this.resizeCursorSvg = resizeCursorSvg;
      resizeStartPosition =
          event.localPosition - _InteractiveFrameEntity._resizeCursorOffset;
      resizeEdge = entityEdge;
    });
  }

  onCursorExit(PointerExitEvent event) {
    if (!resizeTapDown && !mode.isResizing()) {
      setState(() => resizeCursorSvg = null);
    }
  }

  onPanStart(DragStartDetails details) {
    resizeTapDown = false;
    late final EntityInteractionMode mode;
    if (resizeCursorSvg != null) {
      mode = EntityInteractionMode.resizing;
      EditorData.startResizeEntityInteraction(widget.entity);
    } else {
      mode = EntityInteractionMode.moving;
      EditorData.startMoveEntityInteraction(widget.entity);
    }
    setState(() {
      this.mode = mode;
    });
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
      FrameData.of(context).moveEntity(widget.entity.key,
          widget.scaling.reverseOffsetProjection(movedProjection));
    } else if (mode.isResizing()) {
      assert(resizeEdge != null);
      final resizedProjection = widget.scaling
          .clampEntityResize(widget.projection, resizeEdge!, resizing);
      FrameData.of(context).resizeEntity(
          widget.entity.key,
          widget.scaling.reverseOffsetProjection(resizedProjection),
          widget.scaling.reverseSizeProjection(resizedProjection));
    }
    setState(() {
      mode = EntityInteractionMode.clickable;
      moving = Offset.zero;
      resizing = Offset.zero;
      resizeCursorSvg = null;
    });
    EditorData.selectEntityInteraction(widget.entity.key);
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

  void onMenuOption(_EntityMenuOption option) {
    if (option == _EntityMenuOption.delete) {
      FrameData.of(context).deleteEntity(widget.entity.key);
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
