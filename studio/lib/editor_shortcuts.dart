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

class CancelAction extends Action<CancelIntent> {
  final UniqueKey? selectAfterCancelEntityKey;

  CancelAction({this.selectAfterCancelEntityKey});

  @override
  Object? invoke(CancelIntent intent) {
    if (kDebugMode) {
      print(
          'CancelAction.invoke selectAfterCancelEntityKey=$selectAfterCancelEntityKey');
    }
    EditorData.clearCurrentInteraction();
    if (selectAfterCancelEntityKey != null) {
      EditorData.selectEntityInteraction(selectAfterCancelEntityKey!);
    }
    return null;
  }
}

class DeleteAction extends ContextAction<DeleteIntent> {
  final UniqueKey deleteEntityKey;

  DeleteAction(this.deleteEntityKey);

  @override
  Object? invoke(DeleteIntent intent, [BuildContext? context]) {
    if (kDebugMode) {
      print('DeleteAction.invoke deleteEntityKey=$deleteEntityKey');
    }
    EditorData.clearCurrentInteraction();
    FrameData.of(context!).deleteEntity(deleteEntityKey);
    return null;
  }
}
