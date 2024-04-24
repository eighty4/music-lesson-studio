import 'dart:ui';

import 'editor_toolbar.dart';

enum EditorLocation {
  insidePane,
  insideToolbar,
  outsideEditor,
}

class CursorLocation {
  final EditorLocation location;
  final Offset position;

  CursorLocation(this.location, this.position);

  factory CursorLocation.fromPosition(position, {required bool mouseHovering}) {
    late final EditorLocation location;
    if (!mouseHovering) {
      location = EditorLocation.outsideEditor;
    } else if (position.dy < EditorToolbar.height) {
      location = EditorLocation.insideToolbar;
    } else {
      location = EditorLocation.insidePane;
    }
    return CursorLocation(location, position);
  }

  bool get isOutsideEditor => location != EditorLocation.outsideEditor;

  bool get isOverToolbar => location == EditorLocation.insideToolbar;

  bool get isOverPane => location == EditorLocation.insidePane;
}
