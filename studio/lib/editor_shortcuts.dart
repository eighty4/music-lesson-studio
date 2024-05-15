import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'editor_data.dart';
import 'frame_data.dart';

class CancelIntent extends Intent {
  const CancelIntent();
}

class DeleteIntent extends Intent {
  const DeleteIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class CancelAction extends Action<CancelIntent> {
  final UniqueKey? selectAfterCancelEntityKey;

  CancelAction({this.selectAfterCancelEntityKey});

  @override
  void invoke(CancelIntent intent) {
    if (kDebugMode) {
      print(
          'CancelAction.invoke selectAfterCancelEntityKey=$selectAfterCancelEntityKey');
    }
    EditorData.clearCurrentInteraction();
    if (selectAfterCancelEntityKey != null) {
      EditorData.selectEntityInteraction(selectAfterCancelEntityKey!);
    }
  }
}

class DeleteAction extends ContextAction<DeleteIntent> {
  final UniqueKey deleteEntityKey;

  DeleteAction(this.deleteEntityKey);

  @override
  void invoke(DeleteIntent intent, [BuildContext? context]) {
    if (kDebugMode) {
      print('DeleteAction.invoke deleteEntityKey=$deleteEntityKey');
    }
    EditorData.clearCurrentInteraction();
    FrameData.of(context!).deleteEntity(deleteEntityKey);
  }
}

class RedoAction extends ContextAction<RedoIntent> {
  @override
  void invoke(RedoIntent intent, [BuildContext? context]) {
    if (kDebugMode) {
      print('RedoAction.invoke');
    }
    FrameData.of(context!).redo();
  }
}

class UndoAction extends ContextAction<UndoIntent> {
  @override
  void invoke(UndoIntent intent, [BuildContext? context]) {
    if (kDebugMode) {
      print('UndoAction.invoke');
    }
    FrameData.of(context!).undo();
  }
}
