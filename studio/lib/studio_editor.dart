import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';

import 'app_styles.dart';
import 'aspect_ratio.dart';
import 'cursor_override.dart';
import 'debug_data.dart';
import 'editor_controls.dart';
import 'editor_dimensions.dart';
import 'editor_pane.dart';
import 'editor_session.dart';
import 'editor_shortcuts.dart';
import 'editor_toolbar.dart';
import 'frame_data.dart';
import 'frame_scaling.dart';
import 'frame_timeline.dart';
import 'get_started.dart';

typedef ProvideSessionParams = EditorSession Function();

Future<void> initializeSession(ProvideSessionParams provideParams) async {}

class StudioEditorApp extends StatelessWidget {
  final ProvideSessionParams provideSessionParams;

  const StudioEditorApp({super.key, required this.provideSessionParams});

  @override
  Widget build(BuildContext context) {
    // todo use WidgetsApp
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Lesson Studio UI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
          body: StudioEditor(provideSessionParams: provideSessionParams)),
    );
  }
}

enum _StudioMode { editorMode, gettingStarted, loadingData }

class StudioEditor extends StatefulWidget {
  final ProvideSessionParams provideSessionParams;

  const StudioEditor({super.key, required this.provideSessionParams});

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
  TabContext tabContext = TabContext.forBrightness(Brightness.dark);
  late final StreamSubscription sessionSubscription;

  @override
  void initState() {
    super.initState();
    sessionSubscription = EditorSession.updates.listen(onEditorSessionUpdate);
    editorSession = widget.provideSessionParams();
    editorSession.refreshLessonData().then(onEditorSessionDataLoad);
  }

  void onEditorSessionDataLoad(EditorSession editorSession) {
    if (!mounted) return;
    setState(() {
      frameData = FrameData(
          frames: editorSession.unit?.frames,
          onFrameDataChange: (FrameDataState frameState) => setState(() {}));
      mode = editorSession.unit == null
          ? _StudioMode.gettingStarted
          : _StudioMode.editorMode;
      if (kDebugMode) {
        print('_StudioEditorState.onEditorSessionDataLoad mode=$mode');
      }
    });
  }

  void onEditorSessionUpdate(EditorSession editorSession) {
    if (!mounted) return;
    if (kDebugMode) {
      print('_StudioEditorState.onEditorSessionUpdate mode=$mode');
    }
    setState(() {
      this.editorSession = editorSession;
    });
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
                        headerHeight: 60,
                      );
                      final frameScaling =
                          FrameScaling.fromEditorDimensions(dimensions);
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          if (kDebugMode)
                            _EditorSection(
                                offset: const Offset(0, 100),
                                size: Size(constraints.maxWidth,
                                    constraints.maxHeight - 100),
                                child: const DebugData()),
                          _EditorSection(
                              offset: dimensions.toolbarOffset,
                              size: dimensions.toolbarSize,
                              child: const EditorToolbar()),
                          const Positioned(
                            top: 25,
                            left: 0,
                            child: LessonHeader(),
                          ),
                          Positioned(
                              top: 30,
                              right: 0,
                              child: EditorControls(
                                aspectRatio: aspectRatio,
                                playButtonEnabled:
                                    frameData.state.hasFrameWithEntities(),
                                onAspectRatioChanged: (aspectRatio) => setState(
                                    () => this.aspectRatio = aspectRatio),
                              )),
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
