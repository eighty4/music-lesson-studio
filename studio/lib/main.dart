import 'package:flutter/material.dart';

import 'editor_session.dart';
import 'studio_editor.dart';

EditorSession initEditorSession() =>
    const EditorSession(apiHost: 'localhost:5173');

void main() {
  runApp(const StudioEditorApp(initEditorSession: initEditorSession));
}
