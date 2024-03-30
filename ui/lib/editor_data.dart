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

  static selectEntityInteraction(Entity entity) {
    _interactionState.add(
        EditorInteraction(selectedEntity: SelectEntityInteraction(entity.key)));
  }

  static startAddEntityInteraction(EntityType entityType) {
    _interactionState
        .add(EditorInteraction(addingEntity: AddEntityInteraction(entityType)));
  }

  static startMoveEntityInteraction(Entity entity) {
    _interactionState.add(
        EditorInteraction(movingEntity: MovingEntityInteraction(entity.key)));
  }

  static startResizeEntityInteraction(Entity entity) {
    _interactionState.add(EditorInteraction(
        resizingEntity: ResizingEntityInteraction(entity.key)));
  }
}

class EditorInteraction {
  AddEntityInteraction? addingEntity;
  MovingEntityInteraction? movingEntity;
  ResizingEntityInteraction? resizingEntity;
  SelectEntityInteraction? selectedEntity;

  EditorInteraction(
      {this.addingEntity,
      this.movingEntity,
      this.resizingEntity,
      this.selectedEntity});
}

class AddEntityInteraction {
  EntityType entityType;

  AddEntityInteraction(this.entityType);
}

class MovingEntityInteraction {
  UniqueKey entityKey;

  MovingEntityInteraction(this.entityKey);
}

class ResizingEntityInteraction {
  UniqueKey entityKey;

  ResizingEntityInteraction(this.entityKey);
}

class SelectEntityInteraction {
  UniqueKey entityKey;

  SelectEntityInteraction(this.entityKey);
}
