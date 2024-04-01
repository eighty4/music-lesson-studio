import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_ui/aspect_ratio.dart';
import 'package:mls_ui/editor_pane.dart';
import 'package:mls_ui/editor_shortcuts.dart';
import 'package:mls_ui/editor_toolbar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): CancelIntent(),
        SingleActivator(LogicalKeyboardKey.delete): DeleteIntent(),
      },
      child: Column(children: [
        EditorToolbar(
            aspectRatio: aspectRatio,
            onAspectRatioChanged: (aspectRatio) =>
                setState(() => this.aspectRatio = aspectRatio)),
        EditorPane(aspectRatio: aspectRatio),
      ]),
    );
  }
}
