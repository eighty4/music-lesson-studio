import 'dart:ui';

import 'package:flutter/foundation.dart';

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
      EntityType.chordChart => const Size(150, 175),
      EntityType.measureChart => const Size(300, 200),
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}
