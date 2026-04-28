import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mls_api/api_types.dart';
import 'package:mls_api/http_client.dart';
import 'package:mls_api/mls_api.dart' as api;

class EditorSession {
  static final StreamController<EditorSession> _controller = StreamController();

  static Stream<EditorSession> get updates => _controller.stream;

  // todo update web path when adding a plan or unit id
  static EditorSession _update(
    EditorSession editorSession, {
    LessonPlan? plan,
    LessonUnit? unit,
  }) {
    final update = EditorSession(
      apiClient: editorSession._apiClient,
      apiHost: editorSession.apiHost,
      plan: plan ?? editorSession.plan,
      unit: unit ?? editorSession.unit,
    );
    _controller.add(update);
    return update;
  }

  static EditorSession of(BuildContext context) {
    final inheritedEditorSession = context
        .dependOnInheritedWidgetOfExactType<InheritedEditorSession>();
    assert(inheritedEditorSession != null);
    return inheritedEditorSession!.editorSession;
  }

  final MlsTokenHttpClient? _apiClient;
  final String apiHost;
  final LessonPlan? plan;
  final LessonUnit? unit;

  EditorSession({
    MlsTokenHttpClient? apiClient,
    required this.apiHost,
    this.plan,
    this.unit,
  }) : _apiClient = apiClient;

  EditorSession.fromSessionParams({
    MlsTokenHttpClient? apiClient,
    required this.apiHost,
    UniqueId? planId,
    UniqueId? unitId,
  }) : _apiClient = apiClient,
       plan = planId == null ? null : LessonPlan(id: planId),
       unit = unitId == null ? null : LessonUnit(id: unitId);

  Future<EditorSession> refreshLessonData() async {
    final fetched = await fetchLessonData();
    return _update(this, plan: fetched.$1, unit: fetched.$2);
  }

  Future<(LessonPlan?, LessonUnit?)> fetchLessonData() async {
    if (plan?.id == null) {
      return (null, null);
    } else if (unit?.id == null) {
      return (
        await api.getLessonPlan(apiHost, plan!.id!, httpClient: _apiClient),
        null,
      );
    } else {
      return api.getLessonUnit(
        apiHost,
        plan!.id!,
        unit!.id!,
        httpClient: _apiClient,
      );
    }
  }

  Future<EditorSession> saveLessonUnitFrames(List<Frame> frames) async {
    final planId =
        plan?.id ?? await api.createLessonPlan(apiHost, httpClient: _apiClient);
    final unitId =
        unit?.id ??
        await api.createLessonUnit(
          apiHost,
          planId,
          frames,
          httpClient: _apiClient,
        );
    if (plan?.id != null && unit?.id != null) {
      await api.updateLessonUnitFrames(
        apiHost,
        planId,
        unitId,
        frames,
        httpClient: _apiClient,
      );
    }
    return EditorSession._update(
      this,
      plan: plan ?? LessonPlan(id: planId),
      unit: LessonUnit(id: unitId, name: unit?.name, frames: frames),
    );
  }

  // todo post to api
  void updateLessonPlanName(String name) {
    EditorSession._update(
      this,
      plan: LessonPlan(id: plan?.id, name: name),
    );
  }

  // todo post to api
  void updateLessonUnitName(String name) {
    EditorSession._update(
      this,
      unit: LessonUnit(id: unit?.id, name: name, frames: unit?.frames),
    );
  }
}

class InheritedEditorSession extends InheritedWidget {
  final EditorSession editorSession;

  const InheritedEditorSession({
    super.key,
    required this.editorSession,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedEditorSession oldWidget) {
    if (kDebugMode) {
      print(
        'InheritedEditorSession.updateShouldNotify ${oldWidget.editorSession != editorSession}',
      );
    }
    return oldWidget.editorSession != editorSession;
  }
}
