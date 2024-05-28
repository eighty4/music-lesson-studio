import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_api/api_types.dart';

import 'editor_data.dart';
import 'editor_shortcuts.dart';
import 'frame_data.dart';
import 'frame_scaling.dart';
import 'frame_widget.dart';

enum AddingEntityState {
  inactive,
  activeOriginUnknown,
  activeOriginSet,
}

class AddingEntity extends StatefulWidget {
  final FrameScaling frameScaling;
  final TabContext tabContext;

  const AddingEntity(
      {super.key, required this.frameScaling, required this.tabContext});

  @override
  State<AddingEntity> createState() => _AddingEntityState();
}

class _AddingEntityState extends State<AddingEntity> {
  Entity? addingEntity;
  Offset cursorPosition = Offset.zero;
  Offset entityOffset = Offset.zero;
  Size entitySizeMin = Size.zero;
  Size entitySize = Size.zero;
  bool mouseHovering = false;
  AddingEntityState state = AddingEntityState.inactive;
  final FocusNode focusNode = FocusNode(debugLabel: 'adding-entity');
  late final StreamSubscription editorInteractionSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub =
        EditorData.interactionState.listen(onEditorInteractionUpdate);
  }

  onEditorInteractionUpdate(EditorInteraction? editorInteraction) {
    final addingEntityType = editorInteraction?.addingEntity?.entityType;
    if (addingEntityType != null) {
      startAddEntityInteraction(addingEntityType);
    } else if (addingEntity != null) {
      resetState();
    }
  }

  startAddEntityInteraction(EntityType entityType) => setState(() {
        addingEntity =
            Entity(type: entityType, offset: Offset.zero, size: Size.zero);
        state = AddingEntityState.activeOriginUnknown;
        entitySizeMin = entitySize =
            widget.frameScaling.projectSize(entityType.defaultSize() / 5);
        FocusScope.of(context).requestFocus(focusNode);
        if (kDebugMode) {
          print(
              '_AddingEntityState.onEditorInteractionUpdate entitySizeMin=Offset(${entitySizeMin.width}, ${entitySizeMin.height}) entityType=$entityType state=$state');
        }
      });

  resetState() => setState(() {
        addingEntity = null;
        cursorPosition = Offset.zero;
        entityOffset = Offset.zero;
        entitySizeMin = Size.zero;
        entitySize = Size.zero;
        mouseHovering = false;
        state = AddingEntityState.inactive;
        focusNode.unfocus(
            disposition: UnfocusDisposition.previouslyFocusedChild);
      });

  @override
  Widget build(BuildContext context) {
    if (addingEntity == null) {
      return const SizedBox();
    }
    return Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): CancelIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            CancelIntent: CancelAction(),
          },
          child: Focus(
            focusNode: focusNode,
            child: SizedBox.fromSize(
                size: widget.frameScaling.frameSize,
                child: GestureDetector(
                  onTapDown: onTapDown,
                  onPanStart: onPanStart,
                  onPanUpdate: onPanUpdate,
                  onPanEnd: onPanEnd,
                  child: MouseRegion(
                      onEnter: onCursorEnter,
                      onHover: onCursorHover,
                      onExit: onCursorExit,
                      child: Stack(
                        children: [
                          if (mouseHovering &&
                              state != AddingEntityState.inactive)
                            FrameEntityWidget(
                              addingEntity!,
                              projection: EntityProjection(
                                  state == AddingEntityState.activeOriginSet
                                      ? entityOffset
                                      : cursorPosition,
                                  entitySize),
                              interactive: false,
                              scaling: widget.frameScaling,
                              tabContext: widget.tabContext,
                            ),
                        ],
                      )),
                )),
          ),
        ));
  }

  onTapDown(TapDownDetails details) {
    assert(addingEntity != null);
    assert(state != AddingEntityState.inactive);
    if (addingEntity != null) {
      setEntityOffset(details.localPosition);
      if (kDebugMode) {
        print(
            '_AddingEntityState.onTapDown entityOffset=${details.localPosition}');
      }
    }
  }

  onPanStart(DragStartDetails details) {
    assert(addingEntity != null);
    assert(state != AddingEntityState.inactive);
    setEntityOffset(details.localPosition);
    if (kDebugMode) {
      print(
          '_AddingEntityState.onPanStart state=$state localPosition=${details.localPosition}');
    }
  }

  setEntityOffset(Offset entityOffset) {
    if (state != AddingEntityState.activeOriginSet) {
      setState(() {
        this.entityOffset = entityOffset;
        state = AddingEntityState.activeOriginSet;
      });
    }
  }

  onPanUpdate(DragUpdateDetails details) {
    assert(addingEntity != null);
    assert(state != AddingEntityState.inactive);
    final delta = details.localPosition - entityOffset;
    setState(() => entitySize = Size(max(entitySizeMin.width, delta.dx),
        max(entitySizeMin.height, delta.dy)));
    if (kDebugMode) {
      print(
          '_AddingEntityState.onPanUpdate delta=$delta entitySize=$entitySize localPosition=${details.localPosition}');
    }
  }

  onPanEnd(DragEndDetails details) {
    assert(addingEntity != null);
    assert(state == AddingEntityState.activeOriginSet);
    final projection = EntityProjection(entityOffset, entitySize);
    final offset = widget.frameScaling.reverseOffsetProjection(projection);
    final size = widget.frameScaling.reverseSizeProjection(projection);
    if (kDebugMode) {
      print(
          '_AddingEntityState.onPanEnd velocity=${details.primaryVelocity} projection.offset=Offset(${projection.offset.dx}, ${projection.offset.dy}) projection.size=Size(${projection.size.width}, ${projection.size.height}) entity.offset=Offset(${offset.dx}, ${offset.dy}) entity.size=Size(${size.width}, ${size.height})');
    }
    FrameData.of(context).addEntity(Entity(
      type: addingEntity!.type,
      offset: offset,
      size: size,
    ));
    EditorData.clearCurrentInteraction();
  }

  onCursorEnter(_) {
    setState(() => mouseHovering = true);
  }

  onCursorHover(PointerHoverEvent event) {
    if (kDebugMode) {
      print('_AddingEntityState.onCursorHover ${event.localPosition}');
    }
    setState(() => cursorPosition = event.localPosition);
  }

  onCursorExit(_) {
    setState(() {
      cursorPosition = Offset.zero;
      mouseHovering = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
    focusNode.dispose();
  }
}
