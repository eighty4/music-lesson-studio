import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mls_api/api_types.dart';

class EditorData {
  static final StreamController<EditorInteraction?> _streamController =
      StreamController.broadcast();

  static Stream<EditorInteraction?> get interactionState =>
      _streamController.stream;

  static EditorInteraction? _latestState;

  static _dispatch(EditorInteraction? next) {
    _streamController.add(_latestState = next);
  }

  static composeMeasureInteraction() {
    _dispatch(EditorInteraction());
  }

  static clearCurrentInteraction() {
    _dispatch(null);
  }

  static closeOpenMenu() {
    _dispatch(EditorInteraction(
      selectedEntity: EditorData._latestState?.selectedEntity,
      addingEntity: EditorData._latestState?.addingEntity,
      resizingEntity: EditorData._latestState?.resizingEntity,
      movingEntity: EditorData._latestState?.movingEntity,
    ));
  }

  static openCanvasMenu() {
    _dispatch(
        EditorInteraction(openCanvasMenu: const OpenCanvasMenuInteraction()));
  }

  static openEntityMenu(UniqueKey entityKey) {
    _dispatch(EditorInteraction(
        openEntityMenu: OpenEntityMenuInteraction(entityKey),
        selectedEntity: SelectEntityInteraction(entityKey)));
  }

  static openThumbnailMenu(UniqueKey frameKey) {
    _dispatch(EditorInteraction(
      openThumbnailMenu: OpenThumbnailMenuInteraction(frameKey),
    ));
  }

  static selectEntityInteraction(UniqueKey entityKey) {
    _dispatch(
        EditorInteraction(selectedEntity: SelectEntityInteraction(entityKey)));
  }

  static startAddEntityInteraction(EntityType entityType) {
    _dispatch(
        EditorInteraction(addingEntity: AddEntityInteraction(entityType)));
  }

  // todo stream projected resize offset to entity details panel
  static startMoveEntityInteraction(Entity entity) {
    _dispatch(
        EditorInteraction(movingEntity: MovingEntityInteraction(entity.key)));
  }

  // todo stream projected resize offset and size to entity details panel
  static startResizeEntityInteraction(Entity entity) {
    _dispatch(EditorInteraction(
        resizingEntity: ResizingEntityInteraction(entity.key)));
  }
}

class EditorInteraction {
  AddEntityInteraction? addingEntity;
  ComposeMeasureInteraction? composeMeasure;
  MovingEntityInteraction? movingEntity;
  OpenCanvasMenuInteraction? openCanvasMenu;
  OpenEntityMenuInteraction? openEntityMenu;
  OpenThumbnailMenuInteraction? openThumbnailMenu;
  ResizingEntityInteraction? resizingEntity;
  SelectEntityInteraction? selectedEntity;

  EditorInteraction(
      {this.addingEntity,
      this.composeMeasure,
      this.movingEntity,
      this.openCanvasMenu,
      this.openEntityMenu,
      this.openThumbnailMenu,
      this.resizingEntity,
      this.selectedEntity});

  @override
  String toString() {
    List<String> s = [];
    if (addingEntity != null) {
      s.add('addingEntity');
    }
    if (composeMeasure != null) {
      s.add('composeMeasure');
    }
    if (movingEntity != null) {
      s.add('movingEntity');
    }
    if (openCanvasMenu != null) {
      s.add('openCanvasMenu');
    }
    if (openEntityMenu != null) {
      s.add('openEntityMenu');
    }
    if (openThumbnailMenu != null) {
      s.add('openThumbnailMenu');
    }
    if (resizingEntity != null) {
      s.add('resizingEntity');
    }
    if (selectedEntity != null) {
      s.add('selectedEntity');
    }
    return 'EditorInteraction{${s.join(',')}}';
  }
}

class AddEntityInteraction {
  EntityType entityType;

  AddEntityInteraction(this.entityType);
}

class ComposeMeasureInteraction {
  UniqueKey? entityKey;

  ComposeMeasureInteraction(this.entityKey);
}

class MovingEntityInteraction {
  UniqueKey entityKey;

  MovingEntityInteraction(this.entityKey);
}

class OpenCanvasMenuInteraction {
  const OpenCanvasMenuInteraction();
}

class OpenEntityMenuInteraction {
  UniqueKey entityKey;

  OpenEntityMenuInteraction(this.entityKey);
}

class OpenThumbnailMenuInteraction {
  UniqueKey frameKey;

  OpenThumbnailMenuInteraction(this.frameKey);
}

class ResizingEntityInteraction {
  UniqueKey entityKey;

  ResizingEntityInteraction(this.entityKey);
}

class SelectEntityInteraction {
  UniqueKey entityKey;

  SelectEntityInteraction(this.entityKey);
}
