import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mls_ui/editor_data.dart';

// todo _EditorPaneState show entities
// todo _EditorPaneState add entity
// todo _EditorPaneState move entity
// todo _EditorPaneState resize entity

class EditorPane extends StatefulWidget {
  const EditorPane({super.key});

  @override
  State<EditorPane> createState() => _EditorPaneState();
}

class _EditorPaneState extends State<EditorPane> {
  Offset cursorPosition = Offset.zero;
  bool hovering = false;
  EditorInteraction? editorInteraction;
  late final StreamSubscription editorInteractionStateSub;

  @override
  void initState() {
    super.initState();
    editorInteractionStateSub = EditorData.interactionState.listen(
        (editorInteraction) =>
            setState(() => this.editorInteraction = editorInteraction));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
            onEnter: (e) => setState(() => hovering = true),
            onExit: (e) => setState(() => hovering = false),
            onHover: (event) => setState(() => cursorPosition = event.position),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hovering && editorInteraction != null)
                  buildEditionInteraction(),
              ],
            )),
      ),
    );
  }

  Widget buildEditionInteraction() {
    if (editorInteraction?.addingEntity != null) {
      return Positioned(
        left: cursorPosition.dx,
        top: cursorPosition.dy,
        child:
            Text(hovering ? "${cursorPosition.dx}x ${cursorPosition.dy}y" : ""),
      );
    } else {
      return Container();
    }
  }

  onTap() {
    if (editorInteraction?.addingEntity != null) {
      EditorData.clearCurrentInteraction();
    }
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionStateSub.cancel();
  }
}
