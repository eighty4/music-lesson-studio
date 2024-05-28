import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mls_api/api_types.dart';
import 'package:mls_api/mls_api.dart' as api;

class EditorSession {
  static final StreamController<EditorSession> _controller = StreamController();

  static Stream<EditorSession> get updates => _controller.stream;

  static void _update(EditorSession editorSession,
      {String? planId, String? unitId}) {
    _controller.add(EditorSession(
        apiHost: editorSession.apiHost,
        planId: planId ?? editorSession.planId,
        unitId: unitId ?? editorSession.unitId));
  }

  static EditorSession of(BuildContext context) {
    final inheritedEditorSession =
        context.dependOnInheritedWidgetOfExactType<InheritedEditorSession>();
    assert(inheritedEditorSession != null);
    return inheritedEditorSession!.editorSession;
  }

  final String apiHost;
  final String? planId;
  final String? unitId;

  const EditorSession({required this.apiHost, this.planId, this.unitId});

  Future<(LessonPlan, LessonUnit?)> fetchLessonData() async {
    assert(planId != null);
    if (unitId == null) {
      return (await api.getLessonPlan(apiHost, planId!), null);
    } else {
      return api.getLessonUnit(apiHost, planId!, unitId!);
    }
  }

  Future<void> saveLessonUnitFrames(List<Frame> frames) async {
    final planId = this.planId ?? await api.createLessonPlan(apiHost);
    final unitId =
        this.unitId ?? await api.createLessonUnit(apiHost, planId, frames);
    if (this.planId == null || this.unitId == null) {
      EditorSession._update(this, planId: planId, unitId: unitId);
    } else {
      await api.updateLessonUnitFrames(apiHost, planId, unitId, frames);
    }
  }
}

class InheritedEditorSession extends InheritedWidget {
  final EditorSession editorSession;

  const InheritedEditorSession(
      {super.key, required this.editorSession, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedEditorSession oldWidget) {
    if (kDebugMode) {
      print(
          'InheritedEditorSession.updateShouldNotify ${oldWidget.editorSession != editorSession}');
    }
    return oldWidget.editorSession != editorSession;
  }
}
