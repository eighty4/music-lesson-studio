import 'package:flutter/material.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_ui/editor_pane.dart';
import 'package:mls_ui/editor_toolbar.dart';

class StudioEditor extends StatelessWidget {
  static final TabContext tabContext =
      TabContext.forBrightness(Brightness.dark);

  const StudioEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      EditorToolbar(),
      EditorPane(),
    ]);
  }
}
