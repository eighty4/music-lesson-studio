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
    EditorData.clearCurrentInteraction();
    FrameData.deleteEntity(entityKey);
    return null;
  }
}
