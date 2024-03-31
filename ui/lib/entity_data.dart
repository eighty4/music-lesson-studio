import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mls_ui/widget_edge.dart';

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

// todo mutability bad, napster good
// todo property map to translate between serializable and widget
class Entity {
  final UniqueKey key;
  final EntityType type;
  Offset offset;
  Size size;

  Entity({required this.type, required this.offset, Size? size})
      : key = UniqueKey(),
        size = size ??
            switch (type) {
              EntityType.chordChart => const Size(150, 175),
              EntityType.measureChart => const Size(300, 200),
              EntityType.paragraphText => throw UnimplementedError(),
              EntityType.hypermediaLink => throw UnimplementedError(),
              EntityType.imageUpload => throw UnimplementedError(),
              EntityType.videoUpload => throw UnimplementedError(),
              EntityType.videoRecord => throw UnimplementedError(),
              EntityType.youTubeEmbed => throw UnimplementedError(),
            };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

// todo instance method or static
(Offset, Size) calculateResize(
    WidgetEdge? edge, Offset offset, Size size, Offset resize) {
  if (edge == null) {
    return (offset, size);
  }
  late final double x;
  late final double y;
  late final double w;
  late final double h;
  if (edge.isRight()) {
    x = offset.dx;
    w = size.width + resize.dx;
  } else if (edge.isLeft()) {
    x = offset.dx + resize.dx;
    w = size.width - resize.dx;
  } else {
    x = offset.dx;
    w = size.width;
  }
  if (edge.isBottom()) {
    y = offset.dy;
    h = size.height + resize.dy;
  } else if (edge.isTop()) {
    y = offset.dy + resize.dy;
    h = size.height - resize.dy;
  } else {
    y = offset.dy;
    h = size.height;
  }
  return (Offset(x, y), Size(w, h));
}
