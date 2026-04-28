import 'package:flutter/foundation.dart';
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
    final inherited = context
        .dependOnInheritedWidgetOfExactType<InheritedCursorOverride>();
    assert(inherited != null);
    return inherited!.cursorOverride;
  }

  final Function(CursorState) onCursorOverride;
  final CursorState _state;

  CursorState get state => _state;

  const CursorOverride({required this.onCursorOverride, CursorState? state})
    : _state = state ?? CursorState.showSystemCursor;

  MouseCursor cursor(MouseCursor display) {
    return switch (state) {
      CursorState.hideSystemCursor => SystemMouseCursors.none,
      CursorState.showSystemCursor => display,
    };
  }

  void hideSystemCursor() => onCursorOverride(CursorState.hideSystemCursor);

  void showSystemCursor() => onCursorOverride(CursorState.showSystemCursor);
}

class InheritedCursorOverride extends InheritedWidget {
  final CursorOverride cursorOverride;

  InheritedCursorOverride({
    super.key,
    required super.child,
    required Function(CursorState) onCursorOverride,
    CursorState? state,
  }) : cursorOverride = CursorOverride(
         onCursorOverride: onCursorOverride,
         state: state ?? CursorState.showSystemCursor,
       );

  @override
  bool updateShouldNotify(covariant InheritedCursorOverride oldWidget) {
    if (kDebugMode) {
      print(
        'InheritedCursorOverride.updateShouldNotify ${oldWidget.cursorOverride.state != cursorOverride.state}',
      );
    }
    return oldWidget.cursorOverride.state != cursorOverride.state;
  }
}
