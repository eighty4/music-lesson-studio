import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:mls_api/api_types.dart';
import 'package:web/web.dart';

import 'editor_session.dart';
import 'studio_editor.dart';

extension type EditorSessionInit(JSObject _) implements JSObject {
  external String apiHost;
  external String? planId;
  external String? unitId;
}

@JS()
external EditorSessionInit? get mlsEditorSession;

EditorSession provideSessionParams() {
  return EditorSession.fromSessionParams(
    apiHost: mlsEditorSession?.apiHost ?? document.location?.host ?? '',
    planId: mlsEditorSession?.planId as UniqueId,
    unitId: mlsEditorSession?.unitId as UniqueId,
  );
}

void main() {
  runApp(const StudioEditorApp(provideSessionParams: provideSessionParams));
}
