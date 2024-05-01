import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:libtab/libtab.dart';

import 'aspect_ratio.dart';
import 'editor_data.dart';
import 'editor_shortcuts.dart';
import 'entity_data.dart';
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
  Frame frame = Frame();
  UniqueKey? selectedEntityKey;
  late final StreamSubscription editorInteractionSub;
  late final StreamSubscription frameDataSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub =
        EditorData.interactionState.listen((editorInteraction) => setState(() {
              addingEntityType = editorInteraction?.addingEntity?.entityType;
              selectedEntityKey = editorInteraction?.selectedEntity?.entityKey;
              cursorTracking = addingEntityType != null;
              if (!cursorTracking) {
                cursorPosition = Offset.zero;
              }
            }));
    frameDataSub = FrameData.currentFrameStream
        .listen((frame) => setState(() => this.frame = frame));
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
      // todo scale for aspect ratio
      width: widget.frameScaling.frameSize.width,
      // todo scale for aspect ratio
      height: widget.frameScaling.frameSize.height,
      decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          ...frame.entities.map((entity) => FrameEntityWidget(
                entity,
                scaling: widget.frameScaling,
                tabContext: widget.tabContext,
              )),
          if (addingEntityType != null) buildAddingEntity()
        ],
      ),
    );
  }

  // todo center adding entity on cursor
  Widget buildAddingEntity() {
    // todo scale for aspect ratio
    final size = addingEntityType!.defaultSize();
    // todo scale for aspect ratio
    final offset =
        widget.frameScaling.clampPanePosition(cursorPosition, entitySize: size);
    return FrameEntityWidget(
      Entity(type: addingEntityType!, offset: offset, size: size),
      interactive: false,
      scaling: widget.frameScaling,
      tabContext: widget.tabContext,
    );
  }

  void onEditorTap() {
    EditorData.clearCurrentInteraction();
    if (addingEntityType != null) {
      final size = addingEntityType!.defaultSize();
      final offset = widget.frameScaling
          .clampPanePosition(cursorPosition, entitySize: size);
      FrameData.addEntity(Entity(
        type: addingEntityType!,
        offset: offset,
        size: size,
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
