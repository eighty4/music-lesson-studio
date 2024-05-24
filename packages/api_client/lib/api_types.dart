import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';

class LessonPlan {
  final String id;
  final String? name;
  final List<LessonUnit> units;

  LessonPlan({required this.id, this.name, List<LessonUnit>? units})
      : units = units ?? const [];

  factory LessonPlan.fromJson(String json) {
    return LessonPlan.fromDecodedJson(jsonDecode(json));
  }

  factory LessonPlan.fromDecodedJson(Map<String, dynamic> decoded) {
    assert(decoded['id'] != null);
    return LessonPlan(
        id: decoded['id'],
        name: decoded['name'],
        units: decoded['units'] == null
            ? null
            : List<LessonUnit>.from(decoded['units']
                .map((unit) => LessonUnit.fromDecodedJson(unit))));
  }
}

class LessonUnit {
  final String? id;
  final String? name;
  final List<Frame> frames;

  LessonUnit({this.id, this.name, List<Frame>? frames})
      : frames = frames ?? const [];

  factory LessonUnit.fromDecodedJson(Map<String, dynamic> decoded) {
    return LessonUnit(
        id: decoded['id'],
        name: decoded['name'],
        frames: decoded['frames'] == null
            ? null
            : List<Frame>.from(decoded['frames']
                .map((frame) => Frame.fromDecodedJson(frame))));
  }

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

  factory Frame.fromDecodedJson(Map<String, dynamic> decoded) {
    assert(decoded['entities'] != null);
    return Frame(
        entities: List<Entity>.from(decoded['entities']
            .map((entity) => Entity.fromDecodedJson(entity))));
  }

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

  Entity({required this.type, required this.offset, Size? size, UniqueKey? key})
      : key = key ?? UniqueKey(),
        size = size ?? type.defaultSize();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;

  factory Entity.fromDecodedJson(Map<String, dynamic> decoded) {
    return Entity(
      type: _entityTypeFromIdentifier(decoded['type']),
      offset: _rectToOffset(decoded['rect']),
      size: _rectToSize(decoded['rect']),
    );
  }

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

EntityType _entityTypeFromIdentifier(String entityTypeIdentifier) =>
    switch (entityTypeIdentifier) {
      'chord' => EntityType.chordChart,
      'measure' => EntityType.measureChart,
      _ => throw Error()
    };

Offset _rectToOffset(Map<String, dynamic> decoded) {
  assert(decoded['x'] != null && decoded['y'] != null);
  return Offset(_numberToDouble(decoded['x']), _numberToDouble(decoded['y']));
}

Size _rectToSize(Map<String, dynamic> decoded) {
  assert(decoded['w'] != null && decoded['h'] != null);
  return Size(_numberToDouble(decoded['w']), _numberToDouble(decoded['h']));
}

double _numberToDouble(dynamic number) {
  if (number is int) {
    return number.toDouble();
  } else if (number is double) {
    return number;
  } else {
    throw Error();
  }
}
