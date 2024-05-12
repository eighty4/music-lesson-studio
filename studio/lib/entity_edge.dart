import 'dart:ui';

const String _resizeSvgAngle45 = 'assets/arrow_45.svg';
const String _resizeSvgAngle135 = 'assets/arrow_135.svg';
const String _resizeSvgHorizontal = 'assets/arrow_horizontal.svg';
const String _resizeSvgVertical = 'assets/arrow_vertical.svg';

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

  String? get cursorSvgPath => switch (this) {
        EntityEdge.topLeft || EntityEdge.bottomRight => _resizeSvgAngle45,
        EntityEdge.bottomLeft || EntityEdge.topRight => _resizeSvgAngle135,
        EntityEdge.top || EntityEdge.bottom => _resizeSvgVertical,
        EntityEdge.left || EntityEdge.right => _resizeSvgHorizontal,
      };
}

EntityEdge? calculateEdgePosition(Offset offset, Size size, double margin) {
  final double cornerMargin = margin * 2;
  if (_isTopEdge(offset, margin)) {
    if (_isLeftEdge(offset, margin) || _isLeftEdge(offset, cornerMargin)) {
      return EntityEdge.topLeft;
    } else if (_isRightEdge(offset, size, margin) ||
        _isRightEdge(offset, size, cornerMargin)) {
      return EntityEdge.topRight;
    } else {
      return EntityEdge.top;
    }
  } else if (_isBottomEdge(offset, size, margin)) {
    if (_isLeftEdge(offset, margin) || _isLeftEdge(offset, cornerMargin)) {
      return EntityEdge.bottomLeft;
    } else if (_isRightEdge(offset, size, margin) ||
        _isRightEdge(offset, size, cornerMargin)) {
      return EntityEdge.bottomRight;
    } else {
      return EntityEdge.bottom;
    }
  } else if (_isLeftEdge(offset, margin)) {
    if (_isBottomEdge(offset, size, cornerMargin)) {
      return EntityEdge.bottomLeft;
    } else if (_isTopEdge(offset, cornerMargin)) {
      return EntityEdge.topLeft;
    } else {
      return EntityEdge.left;
    }
  } else if (_isRightEdge(offset, size, margin)) {
    if (_isBottomEdge(offset, size, cornerMargin)) {
      return EntityEdge.bottomRight;
    } else if (_isTopEdge(offset, cornerMargin)) {
      return EntityEdge.topRight;
    } else {
      return EntityEdge.right;
    }
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
