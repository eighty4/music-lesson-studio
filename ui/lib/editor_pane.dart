import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';

import 'app_styles.dart';
import 'aspect_ratio.dart';
import 'editor_data.dart';
import 'editor_shortcuts.dart';
import 'entity_data.dart';
import 'frame_canvas.dart';
import 'frame_data.dart';
import 'frame_menu.dart';
import 'frame_scaling.dart';
import 'frame_widget.dart';

enum CanvasMenuOption { paste }

final canvasMenuOptions =
    CanvasMenuOption.values.map((v) => FrameMenuOption(v.name, v)).toList();

class EditorPane extends StatefulWidget {
  final FrameAspectRatio aspectRatio;
  final FrameScaling frameScaling;
  final TabContext tabContext;

  const EditorPane(
      {super.key,
      required this.aspectRatio,
      required this.frameScaling,
      required this.tabContext});

  @override
  State<EditorPane> createState() => _EditorPaneState();
}

class _EditorPaneState extends State<EditorPane> {
  EntityType? addingEntityType;
  Offset cursorPosition = Offset.zero;
  bool cursorTracking = false;
  FocusNode focusNode = FocusNode(debugLabel: "editor-pane");
  UniqueKey? selectedEntityKey;
  late FrameCanvas frameCanvas;
  late final StreamSubscription editorInteractionSub;
  late final StreamSubscription frameDataSub;

  @override
  void initState() {
    super.initState();
    setFrame(Frame());
    editorInteractionSub =
        EditorData.interactionState.listen((editorInteraction) => setState(() {
              addingEntityType = editorInteraction?.addingEntity?.entityType;
              selectedEntityKey = editorInteraction?.selectedEntity?.entityKey;
              cursorTracking = addingEntityType != null;
              if (!cursorTracking) {
                cursorPosition = Offset.zero;
              }
            }));
    frameDataSub = FrameData.currentFrameStream.listen(setFrame);
  }

  setFrame(Frame frame) {
    setState(() => frameCanvas = FrameCanvas(
        frame: frame,
        frameScaling: widget.frameScaling,
        interactive: true,
        tabContext: widget.tabContext));
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Center(child: buildFrameCanvas());
    widget = buildInteractionWidgets(widget);
    if (cursorTracking) {
      widget = MouseRegion(
        onHover: (event) =>
            setState(() => cursorPosition = event.localPosition),
        child: widget,
      );
    }
    return Expanded(child: widget);
  }

  Widget buildInteractionWidgets(Widget child) {
    return Actions(
        actions: <Type, Action<Intent>>{
          if (addingEntityType != null) CancelIntent: CancelAction(),
        },
        child: Focus(
            focusNode: focusNode,
            autofocus: true,
            child: GestureDetector(
                onTap: onEditorTap,
                child: FrameMenu(
                  predicate: (editorInteraction) =>
                      editorInteraction.openCanvasMenu != null,
                  disabled: const [CanvasMenuOption.paste],
                  options: canvasMenuOptions,
                  callback: (option) {
                    if (kDebugMode) {
                      print(option);
                    }
                  },
                  child: GestureDetector(
                    onSecondaryTap: () => EditorData.openCanvasMenu(),
                    child: child,
                  ),
                ))));
  }

  Widget buildFrameCanvas() {
    return Container(
      width: widget.frameScaling.frameSize.width,
      height: widget.frameScaling.frameSize.height,
      decoration: BoxDecoration(
          border: Border.all(color: AppStyles.frameCanvasBorderColor)),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          frameCanvas,
          if (addingEntityType != null) buildAddingEntity()
        ],
      ),
    );
  }

  Widget buildAddingEntity() {
    final entitySize = addingEntityType!.defaultSize();
    final canvasSize = widget.frameScaling.projectSize(entitySize);
    final canvasOffset = widget.frameScaling
        .clampPanePosition(cursorPosition, entitySize: canvasSize);
    return FrameEntityWidget(
      Entity(type: addingEntityType!, offset: Offset.zero, size: Size.zero),
      projection: EntityProjection(canvasOffset, canvasSize),
      interactive: false,
      scaling: widget.frameScaling,
      tabContext: widget.tabContext,
    );
  }

  void onEditorTap() {
    EditorData.clearCurrentInteraction();
    if (addingEntityType != null) {
      final canvasSize = addingEntityType!.defaultSize();
      final canvasOffset = widget.frameScaling
          .clampPanePosition(cursorPosition, entitySize: canvasSize);
      FrameData.addEntity(Entity(
        type: addingEntityType!,
        offset: widget.frameScaling
            .reverseOffsetProjection(EntityProjection.fromOffset(canvasOffset)),
        size: canvasSize,
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
    focusNode.dispose();
    frameDataSub.cancel();
  }
}
