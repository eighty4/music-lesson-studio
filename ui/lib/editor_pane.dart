import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mls_ui/aspect_ratio.dart';
import 'package:mls_ui/editor_data.dart';
import 'package:mls_ui/entity_data.dart';
import 'package:mls_ui/frame_canvas.dart';
import 'package:mls_ui/frame_data.dart';
import 'package:mls_ui/frame_scaling.dart';

class EditorPane extends StatefulWidget {
  final FrameAspectRatio aspectRatio;

  const EditorPane({super.key, required this.aspectRatio});

  @override
  State<EditorPane> createState() => _EditorPaneState();
}

class _EditorPaneState extends State<EditorPane> {
  EntityType? addingEntityType;
  bool mouseHovering = false;

  // todo scale for aspect ratio
  Offset paneCursorPosition = Offset.zero;
  UniqueKey? selectedEntityKey;
  late final StreamSubscription editorInteractionSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub =
        EditorData.interactionState.listen((editorInteraction) => setState(() {
              addingEntityType = editorInteraction?.addingEntity?.entityType;
              selectedEntityKey = editorInteraction?.selectedEntity?.entityKey;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: EditorScaling(
            aspectRatio: widget.aspectRatio,
            cursorPosition: paneCursorPosition,
            builder: (BuildContext context, FrameScaling frameScaling) {
              return MouseRegion(
                onEnter: (e) => setState(() => mouseHovering = true),
                onExit: (e) => setState(() => mouseHovering = false),
                onHover: (event) =>
                    // todo use event.globalPosition to track Offset.dx when cursor is above toolbar
                    // todo scale for aspect ratio
                    setState(() => paneCursorPosition = event.localPosition),
                child: EditorSurface(
                    addingEntityType: addingEntityType,
                    mouseHovering: mouseHovering,
                    frameScaling: frameScaling,
                    selectedEntityKey: selectedEntityKey,
                    child: FrameCanvas(
                      addingEntityType: addingEntityType,
                      scaling: frameScaling,
                    )),
              );
            }));
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
  }
}

typedef EditorBuilder = Widget Function(
    BuildContext context, FrameScaling scaling);

class EditorScaling extends StatelessWidget {
  final FrameAspectRatio aspectRatio;
  final EditorBuilder builder;
  final Offset cursorPosition;

  const EditorScaling(
      {super.key,
      required this.aspectRatio,
      required this.builder,
      required this.cursorPosition});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return builder(
          context,
          FrameScaling.fromConstraints(
            constraints,
            aspectRatio: aspectRatio,
            paneCursorPosition: cursorPosition,
          ));
    });
  }
}

class EditorSurface extends StatelessWidget {
  final EntityType? addingEntityType;
  final Widget child;
  final bool mouseHovering;
  final FrameScaling frameScaling;
  final UniqueKey? selectedEntityKey;

  const EditorSurface(
      {super.key,
      this.addingEntityType,
      required this.child,
      required this.mouseHovering,
      required this.frameScaling,
      this.selectedEntityKey});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onEditorTap,
        child: Center(
          child: child,
        ));
  }

  onEditorTap() {
    if (mouseHovering) {
      if (addingEntityType != null) {
        EditorData.clearCurrentInteraction();
        FrameData.addEntity(addingEntityType!, frameScaling);
      } else if (selectedEntityKey != null) {
        EditorData.clearCurrentInteraction();
      }
    }
  }
}
