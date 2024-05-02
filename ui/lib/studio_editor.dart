import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';

import 'aspect_ratio.dart';
import 'debug_data.dart';
import 'editor_data.dart';
import 'editor_dimensions.dart';
import 'editor_header.dart';
import 'editor_pane.dart';
import 'editor_shortcuts.dart';
import 'editor_toolbar.dart';
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
  bool globalCursorTracking = false;
  Offset globalCursorPosition = Offset.zero;
  TabContext tabContext = TabContext.forBrightness(Brightness.dark);
  late final StreamSubscription interactionSubscription;

  @override
  void initState() {
    super.initState();
    interactionSubscription = EditorData.interactionState.listen((event) {
      final globalCursorTrackingAfterUpdate = event?.addingEntity != null;
      if (globalCursorTrackingAfterUpdate != globalCursorTracking) {
        setState(() {
          globalCursorTracking = globalCursorTrackingAfterUpdate;
          globalCursorPosition = Offset.zero;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): CancelIntent(),
        SingleActivator(LogicalKeyboardKey.backspace): DeleteIntent(),
        SingleActivator(LogicalKeyboardKey.delete): DeleteIntent(),
      },
      child: MouseRegion(
        onHover: globalCursorTracking ? onCursorUpdate : null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dimensions = EditorDimensions.fromConstraints(
              constraints,
              aspectRatio: aspectRatio,
              headerHeight: EditorHeader.height,
            );
            final frameScaling = FrameScaling.fromEditorDimensions(dimensions);
            return Stack(
              fit: StackFit.expand,
              children: [
                if (kDebugMode)
                  EditorSection(
                      offset: const Offset(0, EditorHeader.height),
                      size: Size(constraints.maxWidth,
                          constraints.maxHeight - EditorHeader.height),
                      child: const DebugData()),
                EditorSection(
                    offset: dimensions.headerOffset,
                    size: dimensions.headerSize,
                    child: EditorHeader(
                        aspectRatio: aspectRatio,
                        lessonPlanName: 'Guitar 101',
                        lessonUnitName: 'Chromatic scale',
                        onAspectRatioChanged: (aspectRatio) =>
                            setState(() => this.aspectRatio = aspectRatio))),
                EditorSection(
                    offset: dimensions.toolbarOffset,
                    size: dimensions.toolbarSize,
                    child: const EditorToolbar()),
                EditorSection(
                    offset: dimensions.frameOffset,
                    size: dimensions.frameSize,
                    child: EditorPane(
                      aspectRatio: aspectRatio,
                      frameScaling: frameScaling,
                      globalCursorPosition: globalCursorPosition,
                      tabContext: tabContext,
                    )),
                EditorSection(
                    offset: dimensions.timelineOffset,
                    size: dimensions.timelineSize,
                    child: FrameTimeline(
                        height: dimensions.timelineSize.height,
                        tabContext: tabContext)),
              ],
            );
          },
        ),
      ),
    );
  }

  void onCursorUpdate(event) {
    setState(() => globalCursorPosition = event.position);
  }

  @override
  void dispose() {
    super.dispose();
    interactionSubscription.cancel();
  }
}

class EditorSection extends StatelessWidget {
  final Offset offset;
  final Size size;
  final Widget child;

  const EditorSection(
      {super.key,
      required this.offset,
      required this.size,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: child,
      ),
    );
  }
}
