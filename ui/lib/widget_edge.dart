import 'dart:ui';

enum WidgetEdge {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

extension WidgetEdgeChecks on WidgetEdge {
  bool isTop() {
    return this == WidgetEdge.topLeft ||
        this == WidgetEdge.top ||
        this == WidgetEdge.topRight;
  }

  bool isRight() {
    return this == WidgetEdge.topRight ||
        this == WidgetEdge.bottomRight ||
        this == WidgetEdge.right;
  }

  bool isBottom() {
    return this == WidgetEdge.bottomLeft ||
        this == WidgetEdge.bottom ||
        this == WidgetEdge.bottomRight;
  }

  bool isLeft() {
    return this == WidgetEdge.topLeft ||
        this == WidgetEdge.bottomLeft ||
        this == WidgetEdge.left;
  }

  bool isHorizontal() {
    return this == WidgetEdge.top || this == WidgetEdge.bottom || isCorner();
  }

  bool isVertical() {
    return this == WidgetEdge.right || this == WidgetEdge.left || isCorner();
  }

  bool isCorner() {
    return this == WidgetEdge.topLeft ||
        this == WidgetEdge.topRight ||
        this == WidgetEdge.bottomRight ||
        this == WidgetEdge.bottomLeft;
  }
}

bool isEdgePosition(Offset offset, Size size, double margin) {
  return calculateEdgePosition(offset, size, margin) != null;
}

WidgetEdge? calculateEdgePosition(Offset offset, Size size, double margin) {
  final top = isTopEdge(offset, margin);
  final left = isLeftEdge(offset, margin);
  final bottom = isBottomEdge(offset, size, margin);
  final right = isRightEdge(offset, size, margin);
  if (top) {
    if (left) {
      return WidgetEdge.topLeft;
    } else if (right) {
      return WidgetEdge.topRight;
    } else {
      return WidgetEdge.top;
    }
  } else if (bottom) {
    if (left) {
      return WidgetEdge.bottomLeft;
    } else if (right) {
      return WidgetEdge.bottomRight;
    } else {
      return WidgetEdge.bottom;
    }
  } else if (left) {
    return WidgetEdge.left;
  } else if (right) {
    return WidgetEdge.right;
  } else {
    return null;
  }
}

bool isTopEdge(Offset offset, double margin) {
  return offset.dy < margin;
}

bool isBottomEdge(Offset offset, Size size, double margin) {
  return offset.dy > size.height - margin;
}

bool isLeftEdge(Offset offset, double margin) {
  return offset.dx < margin;
}

bool isRightEdge(Offset offset, Size size, double margin) {
  return offset.dx > size.width - margin;
}
