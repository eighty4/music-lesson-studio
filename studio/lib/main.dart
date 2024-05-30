import 'package:flutter/material.dart';

import 'editor_session.dart';
import 'studio_editor.dart';

void main() {
  runApp(StudioEditorApp(
      provideSessionParams: () => EditorSession(apiHost: 'localhost:5173')));
}
