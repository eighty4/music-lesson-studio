import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_api/api_types.dart';

import 'app_styles.dart';
import 'aspect_ratio.dart';
import 'cursor_override.dart';
import 'debug_data.dart';
import 'editor_dimensions.dart';
import 'editor_header.dart';
import 'editor_pane.dart';
import 'editor_session.dart';
import 'editor_shortcuts.dart';
import 'editor_toolbar.dart';
import 'frame_data.dart';
import 'frame_scaling.dart';
import 'frame_timeline.dart';
import 'get_started.dart';

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

enum _StudioMode { editorMode, gettingStarted, loadingData }

class StudioEditor extends StatefulWidget {
  final InitEditorSession initEditorSession;

  const StudioEditor({super.key, required this.initEditorSession});

  @override
  State<StudioEditor> createState() => _StudioEditorState();
}

// todo customize tab context ui
class _StudioEditorState extends State<StudioEditor> {
  FrameAspectRatio aspectRatio = FrameAspectRatio.sixteenTen;
  CursorState cursorState = CursorState.showSystemCursor;
  late EditorSession editorSession;
  late final FrameData frameData;
  _StudioMode mode = _StudioMode.loadingData;
  late final LessonPlan lessonPlan;
  late final LessonUnit lessonUnit;
  TabContext tabContext = TabContext.forBrightness(Brightness.dark);
  late final StreamSubscription sessionSubscription;

  @override
  void initState() {
    super.initState();
    editorSession = widget.initEditorSession();
    sessionSubscription = EditorSession.updates.listen(onEditorSessionUpdate);
    if (editorSession.planId == null) {
      initLessonData(LessonPlan(), null);
    } else {
      // todo handle error
      editorSession.fetchLessonData().then((lessonData) {
        if (!mounted) return;
        setState(() => initLessonData(lessonData.$1, lessonData.$2));
      });
    }
  }

  void initLessonData(LessonPlan lessonPlan, LessonUnit? lessonUnit) {
    mode = lessonUnit == null
        ? _StudioMode.gettingStarted
        : _StudioMode.editorMode;
    this.lessonUnit = lessonUnit ?? LessonUnit();
    this.lessonPlan = lessonPlan;
    frameData = FrameData(
        frames: this.lessonUnit.frames,
        onFrameDataChange: (FrameDataState frameState) => setState(() {}));
  }

  void onEditorSessionUpdate(editorSession) {
    if (kDebugMode) {
      print('_StudioEditorState.onEditorSessionUpdate $editorSession');
    }
    setState(() => this.editorSession = editorSession);
  }

  @override
  Widget build(BuildContext context) {
    if (mode == _StudioMode.loadingData) {
      return const Center(child: Text('Loading data'));
    } else if (mode == _StudioMode.gettingStarted) {
      return GetStartedLanding(
          onNavToEditor: () => setState(() => mode = _StudioMode.editorMode));
    }
    return InheritedEditorSession(
        editorSession: editorSession,
        child: InheritedFrameData(
          frameData: frameData,
          child: InheritedCursorOverride(
            onCursorOverride: (cursorState) =>
                setState(() => this.cursorState = cursorState),
            state: cursorState,
            child: Shortcuts(
              shortcuts: const <ShortcutActivator, Intent>{
                SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
                    UndoIntent(),
                // todo is redo with `meta + shift + z` possible instead of `meta + y`
                SingleActivator(LogicalKeyboardKey.keyY, meta: true):
                    RedoIntent(),
                SingleActivator(LogicalKeyboardKey.escape): CancelIntent(),
                SingleActivator(LogicalKeyboardKey.backspace): DeleteIntent(),
                SingleActivator(LogicalKeyboardKey.delete): DeleteIntent(),
              },
              child: MouseRegion(
                cursor: cursorState.cursor(),
                child: Container(
                  color: AppStyles.editorBackgroundColor,
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
                                size: Size(
                                    constraints.maxWidth,
                                    constraints.maxHeight -
                                        EditorHeader.height),
                                child: const DebugData()),
                          _EditorSection(
                              offset: dimensions.headerOffset,
                              size: dimensions.headerSize,
                              child: EditorHeader(
                                  aspectRatio: aspectRatio,
                                  lessonPlanName: 'Guitar 101',
                                  lessonUnitName: 'Chromatic scale',
                                  onAspectRatioChanged: (aspectRatio) =>
                                      setState(() =>
                                          this.aspectRatio = aspectRatio))),
                          _EditorSection(
                              offset: dimensions.toolbarOffset,
                              size: dimensions.toolbarSize,
                              child: const EditorToolbar()),
                          _EditorSection(
                              offset: dimensions.frameOffset,
                              size: dimensions.frameSize,
                              child: EditorPane(
                                currentFrame: frameData.state.currentFrame,
                                frameScaling: frameScaling,
                                tabContext: tabContext,
                              )),
                          _EditorSection(
                              offset: dimensions.timelineOffset,
                              size: dimensions.timelineSize,
                              child: FrameTimeline(
                                  currentFrame: frameData.state.currentFrame,
                                  frames: frameData.state.frames,
                                  height: dimensions.timelineSize.height / 2,
                                  tabContext: tabContext)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
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
