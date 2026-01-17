import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_api/api_types.dart';

import 'app_styles.dart';
import 'cursor_override.dart';
import 'editor_interaction.dart';
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

  const FrameEntityWidget(
    this.entity, {
    super.key,
    this.interactive = true,
    required this.projection,
    required this.scaling,
    required this.tabContext,
  });

  @override
  Widget build(BuildContext context) {
    return interactive
        ? _InteractiveFrameEntity(
            entity,
            projection: projection,
            scaling: scaling,
            tabContext: tabContext,
          )
        : _NonInteractiveFrameEntity(
            entity,
            projection: projection,
            tabContext: tabContext,
          );
  }
}

class _NonInteractiveFrameEntity extends StatelessWidget {
  final Entity entity;
  final EntityProjection projection;
  final TabContext tabContext;

  const _NonInteractiveFrameEntity(
    this.entity, {
    required this.tabContext,
    required this.projection,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: projection.offset.dx,
      top: projection.offset.dy,
      child: EntityContent(
        entity,
        tabContext: tabContext,
        size: projection.size,
      ),
    );
  }
}

enum _EntityMenuOption { copy, paste, delete }

final _entityMenuOptions = _EntityMenuOption.values
    .map((v) => FrameMenuOption(v.name, v))
    .toList();

enum _EntityMode { unclickable, clickable, selected, moving, resizing }

extension on _EntityMode {
  bool isClickable() {
    return this != _EntityMode.unclickable &&
        (this == _EntityMode.clickable || this == _EntityMode.selected);
  }

  bool isSelected() {
    return this == _EntityMode.selected;
  }

  bool isMoving() {
    return this == _EntityMode.moving;
  }

  bool isResizing() {
    return this == _EntityMode.resizing;
  }

  bool isMovableOrResizable() {
    return isClickable() || isMoving() || isResizing();
  }

  bool isCancelable() {
    return isMoving() || isResizing();
  }

  Color get highlightColor => switch (this) {
    _EntityMode.moving ||
    _EntityMode.resizing => AppStyles.entityActiveBorderColor,
    _EntityMode.selected => AppStyles.entitySelectedBorderColor,
    _ => AppStyles.transparentColor,
  };
}

class _InteractiveFrameEntity extends StatefulWidget {
  static const double _borderWidth = 3;
  static const double _resizeHitTestWidth = 5;
  static const double _resizeCursorSize = 20;
  static const Offset _resizeCursorOffset = Offset(
    _resizeCursorSize / 2,
    _resizeCursorSize / 2,
  );

  final Entity entity;
  final EntityProjection projection;
  final FrameScaling scaling;
  final TabContext tabContext;

  const _InteractiveFrameEntity(
    this.entity, {
    required this.projection,
    required this.scaling,
    required this.tabContext,
  });

  @override
  State<StatefulWidget> createState() {
    return _InteractiveFrameEntityState();
  }
}

class _InteractiveFrameEntityState extends State<_InteractiveFrameEntity> {
  _EntityMode mode = _EntityMode.clickable;
  Offset moving = Offset.zero;
  Offset resizing = Offset.zero;
  String? resizeCursorSvg;
  Offset resizeCursorPosition = Offset.zero;
  EntityEdge? resizeEdge;
  Offset resizeStartPosition = Offset.zero;
  bool resizeTapDown = false;
  late final StreamSubscription editorInteractionSub;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(debugLabel: 'entity-${widget.entity.type.name}');
    editorInteractionSub = EditorData.interactionState.listen(
      (editorInteraction) => setState(() {
        if (editorInteraction?.movingEntity?.entityKey == widget.entity.key) {
          mode = _EntityMode.moving;
        } else if (editorInteraction?.resizingEntity?.entityKey ==
            widget.entity.key) {
          mode = _EntityMode.resizing;
        } else if (editorInteraction?.selectedEntity?.entityKey ==
            widget.entity.key) {
          mode = _EntityMode.selected;
        } else if (editorInteraction?.addingEntity != null) {
          mode = _EntityMode.unclickable;
        } else {
          mode = _EntityMode.clickable;
        }
        if (mode.isSelected() || mode.isCancelable()) {
          FocusScope.of(context).requestFocus(focusNode);
        } else {
          focusNode.unfocus(
            disposition: UnfocusDisposition.previouslyFocusedChild,
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projection = switch (mode) {
      _EntityMode.moving => widget.scaling.clampEntityMove(
        widget.projection,
        moving,
      ),
      _EntityMode.resizing => widget.scaling.clampEntityResize(
        widget.projection,
        resizeEdge!,
        resizing,
      ),
      _ => widget.projection,
    };
    return Positioned(
      left: projection.offset.dx,
      top: projection.offset.dy,
      child: FrameMenu<_EntityMenuOption>(
        callback: onMenuOption,
        disabled: const [_EntityMenuOption.copy, _EntityMenuOption.paste],
        options: _entityMenuOptions,
        predicate: (interaction) =>
            interaction.openEntityMenu?.entityKey == widget.entity.key,
        child: buildInteractions(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              buildEntity(projection),
              buildHighlight(projection),
              if (resizeCursorSvg != null) _buildResizeCursor(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInteractions({required Widget child}) {
    return Actions(
      actions: <Type, Action<Intent>>{
        if (mode.isCancelable())
          CancelIntent: CancelAction(
            selectAfterCancelEntityKey: widget.entity.key,
          ),
        if (!mode.isCancelable() && mode.isSelected())
          CancelIntent: CancelAction(),
        if (mode.isSelected()) DeleteIntent: DeleteAction(widget.entity.key),
      },
      child: Focus(
        focusNode: focusNode,
        child: MouseRegion(
          cursor: CursorOverride.of(context).cursor(MouseCursor.defer),
          onHover: onCursorHover,
          onExit: onCursorExit,
          child: GestureDetector(
            onPanStart: mode.isMovableOrResizable() ? onPanStart : null,
            onPanUpdate: mode.isMovableOrResizable() ? onPanUpdate : null,
            onPanCancel: onPanCancel,
            onPanEnd: mode.isMovableOrResizable() ? onPanEnd : null,
            onTap: mode.isClickable() ? onLeftClick : null,
            onSecondaryTap: onRightClick,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget buildEntity(EntityProjection projection) {
    return SizedBox(
      width: projection.size.width,
      height: projection.size.height,
      child: EntityContent(
        widget.entity,
        size: projection.size,
        tabContext: widget.tabContext,
      ),
    );
  }

  Widget buildHighlight(EntityProjection projection) {
    return Container(
      width: projection.size.width,
      height: projection.size.height,
      decoration: BoxDecoration(
        border: Border.all(
          color: mode.highlightColor,
          width: _InteractiveFrameEntity._borderWidth,
        ),
      ),
    );
  }

  Positioned _buildResizeCursor() {
    assert(resizeCursorSvg != null);
    assert(resizeEdge != null);
    late final double x;
    late final double y;
    if (resizeEdge!.isTop()) {
      y = resizeCursorPosition.dy;
    } else {
      y = resizeCursorPosition.dy + resizing.dy;
    }
    if (resizeEdge!.isLeft()) {
      x = resizeCursorPosition.dx;
    } else {
      x = resizeCursorPosition.dx + resizing.dx;
    }
    return Positioned(
      top: y,
      left: x,
      child: SvgPicture.asset(
        resizeCursorSvg!,
        height: _InteractiveFrameEntity._resizeCursorSize,
        width: _InteractiveFrameEntity._resizeCursorSize,
      ),
    );
  }

  onCursorHover(PointerHoverEvent event) {
    assert(!mode.isResizing());
    setState(() {
      resizeEdge = calculateEdgePosition(
        event.localPosition,
        widget.projection.size,
        _InteractiveFrameEntity._resizeHitTestWidth,
      );
      if (resizeEdge == null) {
        CursorOverride.of(context).showSystemCursor();
      } else {
        CursorOverride.of(context).hideSystemCursor();
      }
      resizeCursorSvg = resizeEdge?.cursorSvgPath;
      resizeCursorPosition =
          event.localPosition - _InteractiveFrameEntity._resizeCursorOffset;
      resizeStartPosition = event.localPosition;
    });
    if (kDebugMode) {
      print(
        'cursor hover resizeCursorPosition=$resizeCursorPosition resizeEdge=$resizeEdge resizeStartPosition=$resizeStartPosition',
      );
    }
  }

  onCursorExit(PointerExitEvent event) {
    if (!resizeTapDown && !mode.isResizing()) {
      setState(() => resizeCursorSvg = null);
      CursorOverride.of(context).showSystemCursor();
    }
    if (kDebugMode) {
      print(
        'cursor exit mode=$mode resizeTapDown=$resizeTapDown resizeCursorSvg=$resizeCursorSvg',
      );
    }
  }

  onPanStart(DragStartDetails details) {
    late final _EntityMode mode;
    if (resizeCursorSvg != null) {
      CursorOverride.of(context).hideSystemCursor();
      mode = _EntityMode.resizing;
      EditorData.startResizeEntityInteraction(widget.entity);
    } else {
      mode = _EntityMode.moving;
      EditorData.startMoveEntityInteraction(widget.entity);
    }
    if (kDebugMode) {
      print('pan start mode=$mode localPosition=${details.localPosition}');
    }
    setState(() => this.mode = mode);
  }

  onPanCancel() {
    if (kDebugMode) {
      print('_InteractiveFrameEntityState.onPanCancel');
    }
    CursorOverride.of(context).showSystemCursor();
  }

  onPanUpdate(DragUpdateDetails details) {
    assert(mode.isMoving() || mode.isResizing());
    if (mode.isMoving()) {
      setState(() => moving += details.delta);
    } else if (mode.isResizing()) {
      setState(() => resizing += details.delta);
    }
    if (kDebugMode) {
      print(
        'pan update localPosition=${details.localPosition} moving=$moving resizing=$resizing',
      );
    }
  }

  onPanEnd(DragEndDetails details) {
    assert(mode.isMoving() || mode.isResizing());
    if (kDebugMode) {
      print(
        'pan end primaryVelocity=${details.primaryVelocity} moving=$moving resizing=$resizing',
      );
    }
    if (mode.isMoving()) {
      final movedProjection = widget.scaling.clampEntityMove(
        widget.projection,
        moving,
      );
      FrameData.of(context).moveEntity(
        widget.entity,
        widget.scaling.reverseOffsetProjection(movedProjection),
      );
    } else if (mode.isResizing()) {
      assert(resizeEdge != null);
      final resizedProjection = widget.scaling.clampEntityResize(
        widget.projection,
        resizeEdge!,
        resizing,
      );
      FrameData.of(context).resizeEntity(
        widget.entity,
        widget.scaling.reverseOffsetProjection(resizedProjection),
        widget.scaling.reverseSizeProjection(resizedProjection),
      );
    }
    setState(() {
      mode = _EntityMode.clickable;
      moving = Offset.zero;
      resizing = Offset.zero;
      resizeCursorSvg = null;
      resizeTapDown = false;
    });
    EditorData.selectEntityInteraction(widget.entity.key);
    CursorOverride.of(context).showSystemCursor();
  }

  onLeftClick() {
    if (kDebugMode) {
      print('_InteractiveFrameEntityState.onLeftClick');
    }
    if (!mode.isMoving()) {
      EditorData.selectEntityInteraction(widget.entity.key);
    }
    setState(() => resizeTapDown = false);
  }

  onRightClick() {
    if (kDebugMode) {
      print('_InteractiveFrameEntityState.onRightClick');
    }
    EditorData.openEntityMenu(widget.entity.key);
  }

  onMenuOption(_EntityMenuOption option) {
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
