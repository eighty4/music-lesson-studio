import 'dart:ui';

import 'package:flutter/foundation.dart';

class LessonUnit {
  final String? id;
  final String name;
  final List<Frame> frames;

  LessonUnit({this.id, required this.name, required this.frames});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'frames': frames,
    };
  }
}

class Frame {
  final UniqueKey key;
  final List<Entity> entities;

  Frame({Iterable<Entity>? entities, UniqueKey? key})
      : key = key ?? UniqueKey(),
        entities = List.of(entities ?? [], growable: false);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Frame && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;

  Map<String, dynamic> toJson() {
    return {'entities': entities};
  }
}

enum EntityType {
  measureChart,
  chordChart,
  paragraphText,
  hypermediaLink,
  imageUpload,
  videoUpload,
  videoRecord,
  youTubeEmbed,
}

extension EntityTypeFns on EntityType {
  Size defaultSize() {
    return switch (this) {
      EntityType.chordChart => const Size(.15, .25),
      EntityType.measureChart => const Size(.4, .3),
      EntityType.paragraphText => throw UnimplementedError(),
      EntityType.hypermediaLink => throw UnimplementedError(),
      EntityType.imageUpload => throw UnimplementedError(),
      EntityType.videoUpload => throw UnimplementedError(),
      EntityType.videoRecord => throw UnimplementedError(),
      EntityType.youTubeEmbed => throw UnimplementedError(),
    };
  }

  String identifier() {
    return switch (this) {
      EntityType.chordChart => 'chord',
      EntityType.measureChart => 'measure',
      EntityType.paragraphText => throw UnimplementedError(),
      EntityType.hypermediaLink => throw UnimplementedError(),
      EntityType.imageUpload => throw UnimplementedError(),
      EntityType.videoUpload => throw UnimplementedError(),
      EntityType.videoRecord => throw UnimplementedError(),
      EntityType.youTubeEmbed => throw UnimplementedError(),
    };
  }
}

// todo property map to translate between serializable and widget
class Entity {
  final UniqueKey key;
  final EntityType type;
  final Offset offset;
  final Size size;

  Entity({required this.type, required this.offset, Size? size})
      : key = UniqueKey(),
        size = size ?? type.defaultSize();

  Entity._mutateFrom(Entity entity, {Offset? offset, Size? size})
      : key = entity.key,
        type = entity.type,
        offset = offset ?? entity.offset,
        size = size ?? entity.size;

  Entity mutate({Offset? offset, Size? size}) =>
      Entity._mutateFrom(this, offset: offset, size: size);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'type': type.identifier(),
      'rect': {
        'x': offset.dx,
        'y': offset.dy,
        'w': size.width,
        'h': size.height,
      },
    };
  }
}
