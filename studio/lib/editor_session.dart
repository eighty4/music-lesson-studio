import 'dart:async';

import 'package:flutter/widgets.dart';

class EditorSession {
  static final StreamController<EditorSession> _controller = StreamController();

  static Stream<EditorSession> get updates => _controller.stream;

  static void update(EditorSession editorSession,
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
}

// final String apiHost;
// final String? authToken;
// final String? planId;
// final String? unitId;
//
// EditorSession(
//     {required this.apiHost, this.authToken, this.planId, this.unitId}) {
//   assert(kIsWeb || authToken != null);
// }
// }

class InheritedEditorSession extends InheritedWidget {
  final EditorSession editorSession;

  const InheritedEditorSession(
      {super.key, required this.editorSession, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedEditorSession oldWidget) {
    return oldWidget.editorSession != editorSession;
  }
}
