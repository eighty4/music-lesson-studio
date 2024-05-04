import 'dart:ui';

enum EntityEdge {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

extension EntityEdgeFns on EntityEdge {
  bool isTop() {
    return this == EntityEdge.topLeft ||
        this == EntityEdge.top ||
        this == EntityEdge.topRight;
  }

  bool isRight() {
    return this == EntityEdge.topRight ||
        this == EntityEdge.bottomRight ||
        this == EntityEdge.right;
  }

  bool isBottom() {
    return this == EntityEdge.bottomLeft ||
        this == EntityEdge.bottom ||
        this == EntityEdge.bottomRight;
  }

  bool isLeft() {
    return this == EntityEdge.topLeft ||
        this == EntityEdge.bottomLeft ||
        this == EntityEdge.left;
  }

  bool isHorizontal() {
    return this == EntityEdge.top || this == EntityEdge.bottom || isCorner();
  }

  bool isVertical() {
    return this == EntityEdge.right || this == EntityEdge.left || isCorner();
  }

  bool isCorner() {
    return this == EntityEdge.topLeft ||
        this == EntityEdge.topRight ||
        this == EntityEdge.bottomRight ||
        this == EntityEdge.bottomLeft;
  }
}

EntityEdge? calculateEdgePosition(Offset offset, Size size, double margin) {
  final top = _isTopEdge(offset, margin);
  final left = _isLeftEdge(offset, margin);
  final bottom = _isBottomEdge(offset, size, margin);
  final right = _isRightEdge(offset, size, margin);
  if (top) {
    if (left) {
      return EntityEdge.topLeft;
    } else if (right) {
      return EntityEdge.topRight;
    } else {
      return EntityEdge.top;
    }
  } else if (bottom) {
    if (left) {
      return EntityEdge.bottomLeft;
    } else if (right) {
      return EntityEdge.bottomRight;
    } else {
      return EntityEdge.bottom;
    }
  } else if (left) {
    return EntityEdge.left;
  } else if (right) {
    return EntityEdge.right;
  } else {
    return null;
  }
}

bool _isTopEdge(Offset offset, double margin) {
  return offset.dy < margin;
}

bool _isBottomEdge(Offset offset, Size size, double margin) {
  return offset.dy > size.height - margin;
}

bool _isLeftEdge(Offset offset, double margin) {
  return offset.dx < margin;
}

bool _isRightEdge(Offset offset, Size size, double margin) {
  return offset.dx > size.width - margin;
}
