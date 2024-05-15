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
import 'editor_session.dart';
import 'editor_shortcuts.dart';
import 'editor_toolbar.dart';
import 'frame_data.dart';
import 'frame_scaling.dart';
import 'frame_timeline.dart';

typedef InitEditorSession = EditorSession Function();

class StudioEditorApp extends StatelessWidget {
  final InitEditorSession initEditorSession;

  const StudioEditorApp({super.key, required this.initEditorSession});

  @override
  Widget build(BuildContext context) {
    // todo use WidgetsApp
    return MaterialApp(
      title: 'Music Lesson Studio UI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(body: StudioEditor(initEditorSession: initEditorSession)),
    );
  }
}

class StudioEditor extends StatefulWidget {
  final InitEditorSession initEditorSession;

  const StudioEditor({super.key, required this.initEditorSession});

  @override
  State<StudioEditor> createState() => _StudioEditorState();
}

// todo customize tab context ui
class _StudioEditorState extends State<StudioEditor> {
  FrameAspectRatio aspectRatio = FrameAspectRatio.sixteenTen;
  late EditorSession editorSession;
  late final FrameData frameData;
  late FrameDataState frameState;
  bool globalCursorTracking = false;
  Offset globalCursorPosition = Offset.zero;
  TabContext tabContext = TabContext.forBrightness(Brightness.dark);
  bool entityResizingActive = false;
  late final StreamSubscription interactionSubscription;
  late final StreamSubscription sessionSubscription;

  @override
  void initState() {
    super.initState();
    frameData = FrameData(onFrameDataChange: onFrameDataChange);
    frameState = frameData.state;
    editorSession = widget.initEditorSession();
    interactionSubscription = EditorData.interactionState.listen((event) {
      final globalCursorTrackingAfterUpdate = event?.addingEntity != null;
      final entityResizingActive = event?.resizingEntity != null;
      if (globalCursorTrackingAfterUpdate != globalCursorTracking ||
          this.entityResizingActive != entityResizingActive) {
        setState(() {
          this.entityResizingActive = entityResizingActive;
          globalCursorTracking = globalCursorTrackingAfterUpdate;
          globalCursorPosition = Offset.zero;
        });
      }
    });
    sessionSubscription = EditorSession.updates
        .listen((event) => setState(() => editorSession = event));
  }

  onFrameDataChange(FrameDataState frameState) =>
      setState(() => this.frameState = frameState);

  @override
  Widget build(BuildContext context) {
    return InheritedEditorSession(
      editorSession: editorSession,
      child: InheritedFrameData(
        frameData: frameData,
        child: Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.keyZ, meta: true): UndoIntent(),
            // todo is redo with `meta + shift + z` possible instead of `meta + y`
            SingleActivator(LogicalKeyboardKey.keyY, meta: true): RedoIntent(),
            SingleActivator(LogicalKeyboardKey.escape): CancelIntent(),
            SingleActivator(LogicalKeyboardKey.backspace): DeleteIntent(),
            SingleActivator(LogicalKeyboardKey.delete): DeleteIntent(),
          },
          child: MouseRegion(
            cursor: entityResizingActive
                ? SystemMouseCursors.none
                : SystemMouseCursors.basic,
            onHover: globalCursorTracking ? onCursorUpdate : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dimensions = EditorDimensions.fromConstraints(
                  constraints,
                  aspectRatio: aspectRatio,
                  headerHeight: EditorHeader.height,
                );
                final frameScaling =
                    FrameScaling.fromEditorDimensions(dimensions);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (kDebugMode)
                      _EditorSection(
                          offset: const Offset(0, EditorHeader.height),
                          size: Size(constraints.maxWidth,
                              constraints.maxHeight - EditorHeader.height),
                          child: const DebugData()),
                    _EditorSection(
                        offset: dimensions.headerOffset,
                        size: dimensions.headerSize,
                        child: EditorHeader(
                            aspectRatio: aspectRatio,
                            lessonPlanName: 'Guitar 101',
                            lessonUnitName: 'Chromatic scale',
                            onAspectRatioChanged: (aspectRatio) => setState(
                                () => this.aspectRatio = aspectRatio))),
                    _EditorSection(
                        offset: dimensions.toolbarOffset,
                        size: dimensions.toolbarSize,
                        child: const EditorToolbar()),
                    _EditorSection(
                        offset: dimensions.frameOffset,
                        size: dimensions.frameSize,
                        child: EditorPane(
                          currentFrame: frameState.currentFrame,
                          frameScaling: frameScaling,
                          globalCursorPosition: globalCursorPosition,
                          tabContext: tabContext,
                        )),
                    _EditorSection(
                        offset: dimensions.timelineOffset,
                        size: dimensions.timelineSize,
                        child: FrameTimeline(
                            currentFrame: frameState.currentFrame,
                            frames: frameState.frames,
                            height: dimensions.timelineSize.height / 2,
                            tabContext: tabContext)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  onCursorUpdate(event) {
    setState(() => globalCursorPosition = event.position);
  }

  @override
  void dispose() {
    super.dispose();
    interactionSubscription.cancel();
    sessionSubscription.cancel();
  }
}

class _EditorSection extends StatelessWidget {
  final Offset offset;
  final Size size;
  final Widget child;

  const _EditorSection(
      {required this.offset, required this.size, required this.child});

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
