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
  double x;
  double y;
  Size size;

  Entity(
      {required this.type,
      required this.x,
      required this.y,
      required this.size})
      : key = UniqueKey();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

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
