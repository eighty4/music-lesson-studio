import 'dart:async';

import 'package:flutter/material.dart';

import 'aspect_ratio.dart';
import 'editor_data.dart';
import 'editor_shortcuts.dart';
import 'entity_data.dart';
import 'frame_canvas.dart';
import 'frame_data.dart';
import 'frame_scaling.dart';

class EditorPane extends StatefulWidget {
  final FrameAspectRatio aspectRatio;
  final FrameScaling frameScaling;
  final bool mouseHovering;

  const EditorPane(
      {super.key,
      required this.aspectRatio,
      required this.frameScaling,
      required this.mouseHovering});

  @override
  State<EditorPane> createState() => _EditorPaneState();
}

class _EditorPaneState extends State<EditorPane> {
  EntityType? addingEntityType;
  FocusNode focusNode = FocusNode(debugLabel: "editor-pane");
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
    return Actions(
        actions: <Type, Action<Intent>>{
          if (addingEntityType != null) CancelIntent: CancelAction(),
        },
        child: Expanded(
          child: Focus(
              focusNode: focusNode,
              autofocus: true,
              child: GestureDetector(
                  onTap: onEditorTap,
                  child: FrameCanvas(
                    addingEntityType: addingEntityType,
                    scaling: widget.frameScaling,
                  ))),
        ));
  }

  onEditorTap() {
    EditorData.clearCurrentInteraction();
    if (addingEntityType != null) {
      FrameData.addEntity(addingEntityType!, widget.frameScaling);
    }
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
    focusNode.dispose();
  }
}
