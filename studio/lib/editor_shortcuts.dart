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
  final UniqueKey? entityKey;

  CancelAction({this.entityKey});

  @override
  Object? invoke(CancelIntent intent) {
    if (kDebugMode) {
      print('CancelAction.invoke entityKey=$entityKey');
    }
    EditorData.clearCurrentInteraction();
    if (entityKey != null) {
      EditorData.selectEntityInteraction(entityKey!);
    }
    return null;
  }
}

class DeleteAction extends Action<DeleteIntent> {
  final UniqueKey entityKey;

  DeleteAction(this.entityKey);

  @override
  Object? invoke(DeleteIntent intent) {
    if (kDebugMode) {
      print('DeleteAction.invoke entityKey=$entityKey');
    }
    EditorData.clearCurrentInteraction();
    FrameData.deleteEntity(entityKey);
    return null;
  }
}
