import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mls_ui/editor_data.dart';
import 'package:mls_ui/entity_content.dart';
import 'package:mls_ui/entity_data.dart';
import 'package:mls_ui/frame_data.dart';
import 'package:mls_ui/frame_widget.dart';
import 'package:mls_ui/studio_editor.dart';

class EditorPane extends StatefulWidget {
  const EditorPane({super.key});

  @override
  State<EditorPane> createState() => _EditorPaneState();
}

class _EditorPaneState extends State<EditorPane> {
  // todo scale for aspect ratio
  Offset cursorPosition = Offset.zero;
  bool hovering = false;
  Frame frame = Frame();
  EditorInteraction? editorInteraction;
  late final StreamSubscription editorInteractionStateSub;
  late final StreamSubscription frameDataSub;

  @override
  void initState() {
    super.initState();
    editorInteractionStateSub = EditorData.interactionState.listen(
        (editorInteraction) =>
            setState(() => this.editorInteraction = editorInteraction));
    frameDataSub = FrameData.currentFrame
        .listen((frame) => setState(() => this.frame = frame));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
            onEnter: (e) => setState(() => hovering = true),
            onExit: (e) => setState(() => hovering = false),
            onHover: (event) =>
                // todo scale for aspect ratio
                setState(() => cursorPosition = event.localPosition),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ...frame.entities.map((entity) => FrameEntityWidget(
                      entity,
                      tabContext: StudioEditor.tabContext,
                    )),
                if (hovering && editorInteraction != null)
                  buildEditorInteraction(),
              ],
            )),
      ),
    );
  }

  Widget buildEditorInteraction() {
    if (editorInteraction?.addingEntity != null) {
      return Positioned(
          // todo scale for aspect ratio
          left: cursorPosition.dx,
          // todo scale for aspect ratio
          top: cursorPosition.dy,
          child: DefaultEntityContent(
              editorInteraction!.addingEntity!.entityType, cursorPosition));
    } else {
      return Container();
    }
  }

  onTap() {
    if (editorInteraction?.addingEntity != null) {
      EditorData.clearCurrentInteraction();
      FrameData.addEntity(Entity(
        type: editorInteraction!.addingEntity!.entityType,
        // todo scale for aspect ratio
        offset: cursorPosition,
      ));
    } else if (editorInteraction?.selectedEntity != null) {
      EditorData.clearCurrentInteraction();
    }
  }

  @override
  void dispose() {
    super.dispose();
    frameDataSub.cancel();
    editorInteractionStateSub.cancel();
  }
}
