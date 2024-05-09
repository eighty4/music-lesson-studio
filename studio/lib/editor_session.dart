import 'package:flutter/widgets.dart';

class EditorSession {
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

class InheritedEditorSession extends InheritedWidget {
  final EditorSession editorSession;

  const InheritedEditorSession(
      {super.key, required this.editorSession, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
