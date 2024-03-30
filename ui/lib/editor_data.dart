import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mls_ui/aspect_ratio.dart';
import 'package:mls_ui/entity_data.dart';

class EditorData {
  static final StreamController<EditorInteraction?> _interactionState =
      StreamController.broadcast();

  static final StreamController<AspectRatioSetting> _aspectRatio =
      StreamController.broadcast();

  static Stream<EditorInteraction?> get interactionState =>
      _interactionState.stream;

  static Stream<AspectRatioSetting> get aspectRatio => _aspectRatio.stream;

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

  static changeAspectRatio(AspectRatioSetting aspectRatio) {
    _aspectRatio.add(aspectRatio);
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
