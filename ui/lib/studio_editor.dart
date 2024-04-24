import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';

import 'aspect_ratio.dart';
import 'editor_pane.dart';
import 'editor_shortcuts.dart';
import 'editor_toolbar.dart';
import 'frame_scaling.dart';

class StudioEditor extends StatefulWidget {
  // todo customize tab context ui
  static final TabContext tabContext =
      TabContext.forBrightness(Brightness.dark);

  const StudioEditor({super.key});

  @override
  State<StudioEditor> createState() => _StudioEditorState();
}

class _StudioEditorState extends State<StudioEditor> {
  FrameAspectRatio aspectRatio = FrameAspectRatio.sixteenNine;
  Offset cursorPosition = Offset.zero;
  bool mouseHovering = false;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): CancelIntent(),
        SingleActivator(LogicalKeyboardKey.backspace): DeleteIntent(),
        SingleActivator(LogicalKeyboardKey.delete): DeleteIntent(),
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final frameScaling = FrameScaling.fromConstraints(
            constraints,
            aspectRatio: aspectRatio,
            cursorPosition: cursorPosition,
            mouseHovering: mouseHovering,
          );
          return MouseRegion(
            onHover: (event) => setState(() => cursorPosition = event.position),
            onEnter: (event) => setState(() => mouseHovering = true),
            onExit: (event) => setState(() => mouseHovering = false),
            child: Column(children: [
              EditorToolbar(
                  aspectRatio: aspectRatio,
                  onAspectRatioChanged: (aspectRatio) =>
                      setState(() => this.aspectRatio = aspectRatio)),
              EditorPane(
                aspectRatio: aspectRatio,
                frameScaling: frameScaling,
                mouseHovering: mouseHovering,
              ),
            ]),
          );
        },
      ),
    );
  }
}
