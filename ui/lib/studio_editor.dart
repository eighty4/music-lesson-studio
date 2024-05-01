import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';

import 'aspect_ratio.dart';
import 'editor_dimensions.dart';
import 'editor_pane.dart';
import 'editor_shortcuts.dart';
import 'editor_toolbar.dart';
import 'frame_data.dart';
import 'frame_scaling.dart';
import 'frame_timeline.dart';

class StudioEditor extends StatefulWidget {
  const StudioEditor({super.key});

  @override
  State<StudioEditor> createState() => _StudioEditorState();
}

// todo customize tab context ui
class _StudioEditorState extends State<StudioEditor> {
  FrameAspectRatio aspectRatio = FrameAspectRatio.sixteenTen;
  bool singleFrame = true;
  TabContext tabContext = TabContext.forBrightness(Brightness.dark);
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
          final editorDimensions = EditorDimensions.fromConstraints(
            constraints,
            aspectRatio: aspectRatio,
            singleFrame: singleFrame,
          );
          final frameScaling =
              FrameScaling.fromEditorDimensions(editorDimensions);
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
                  tabContext: tabContext,
                ),
                FrameTimeline(
                    size: editorDimensions.timelineSize,
                    tabContext: tabContext),
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
