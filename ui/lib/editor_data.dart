import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mls_ui/frame_data.dart';

class EditorData {
  static final StreamController<EditorInteraction?> _interactionState =
      StreamController.broadcast();

  static Stream<EditorInteraction?> get interactionState =>
      _interactionState.stream;

  static clearCurrentInteraction() {
    _interactionState.add(EditorInteraction());
  }

  static startAddEntityInteraction(entityType) {
    _interactionState
        .add(EditorInteraction(addingEntity: AddEntityInteraction(entityType)));
  }

  static startMoveEntityInteraction(entityKey) {
    _interactionState
        .add(EditorInteraction(movingEntity: MoveEntityInteraction(entityKey)));
  }
}

class EditorInteraction {
  AddEntityInteraction? addingEntity;
  MoveEntityInteraction? movingEntity;

  EditorInteraction({this.addingEntity, this.movingEntity});
}

class AddEntityInteraction {
  EntityType entityType;

  AddEntityInteraction(this.entityType);
}

class MoveEntityInteraction {
  UniqueKey entityKey;

  MoveEntityInteraction(this.entityKey);
}
