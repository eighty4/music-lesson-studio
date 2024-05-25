import 'package:flutter/widgets.dart';

enum CursorState { hideSystemCursor, showSystemCursor }

extension SystemCursorFn on CursorState {
  MouseCursor cursor() {
    return switch (this) {
      CursorState.hideSystemCursor => SystemMouseCursors.none,
      CursorState.showSystemCursor => MouseCursor.defer,
    };
  }
}

class CursorOverride {
  static CursorOverride of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedCursorOverride>();
    assert(inherited != null);
    return inherited!.cursorOverride;
  }

  final Function(CursorState) onCursorOverride;

  const CursorOverride({required this.onCursorOverride});

  hideSystemCursor() => onCursorOverride(CursorState.hideSystemCursor);

  showSystemCursor() => onCursorOverride(CursorState.showSystemCursor);
}

class InheritedCursorOverride extends InheritedWidget {
  final CursorOverride cursorOverride;

  InheritedCursorOverride(
      {super.key,
      required super.child,
      required Function(CursorState) onCursorOverride})
      : cursorOverride = CursorOverride(onCursorOverride: onCursorOverride);

  @override
  bool updateShouldNotify(covariant InheritedCursorOverride oldWidget) {
    return oldWidget.cursorOverride != cursorOverride;
  }
}
