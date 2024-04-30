import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';

import 'aspect_ratio.dart';
import 'editor_pane.dart';
import 'editor_shortcuts.dart';
import 'editor_toolbar.dart';
import 'frame_data.dart';
import 'frame_scaling.dart';
import 'frame_timeline.dart';

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
  bool singleFrame = true;
  late final StreamSubscription framesSubscription;

  @override
  void initState() {
    super.initState();
    framesSubscription = FrameData.allFramesStream
        .listen((frames) => setState(() => singleFrame = frames.length == 1));
  }

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
            singleFrame: singleFrame,
          );
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EditorToolbar(
                    aspectRatio: aspectRatio,
                    onAspectRatioChanged: (aspectRatio) =>
                        setState(() => this.aspectRatio = aspectRatio)),
                EditorPane(
                  aspectRatio: aspectRatio,
                  frameScaling: frameScaling,
                ),
                FrameTimeline(size: frameScaling.timelineSize),
              ]);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    framesSubscription.cancel();
  }
}
