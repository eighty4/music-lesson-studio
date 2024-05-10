import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mls_studio/entity_edge.dart';

void main() {
  test('calculateEdgePosition in middle', () {
    const offset = Offset(50, 50);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin), isNull);
  });
  test('calculateEdgePosition on top', () {
    const offset = Offset(50, 4);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin), equals(EntityEdge.top));
  });
  test('calculateEdgePosition on bottom', () {
    const offset = Offset(50, 96);
    const size = Size(100, 100);
    const double margin = 5;
    expect(
        calculateEdgePosition(offset, size, margin), equals(EntityEdge.bottom));
  });
  test('calculateEdgePosition on left', () {
    const offset = Offset(4, 50);
    const size = Size(100, 100);
    const double margin = 5;
    expect(
        calculateEdgePosition(offset, size, margin), equals(EntityEdge.left));
  });
  test('calculateEdgePosition on right', () {
    const offset = Offset(96, 50);
    const size = Size(100, 100);
    const double margin = 5;
    expect(
        calculateEdgePosition(offset, size, margin), equals(EntityEdge.right));
  });

  // topLeft

  test('calculateEdgePosition on top left', () {
    const offset = Offset(4, 4);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.topLeft));
  });
  test('calculateEdgePosition on top left, further from top', () {
    const offset = Offset(4, 9);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.topLeft));
  });
  test('calculateEdgePosition on top left, further from left', () {
    const offset = Offset(9, 4);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.topLeft));
  });
  test('calculateEdgePosition too far from top left', () {
    const offset = Offset(9, 9);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin), equals(null));
  });

  // topRight

  test('calculateEdgePosition on top right', () {
    const offset = Offset(96, 4);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.topRight));
  });
  test('calculateEdgePosition on top right, further from top', () {
    const offset = Offset(96, 9);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.topRight));
  });
  test('calculateEdgePosition on top right, further from right', () {
    const offset = Offset(91, 4);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.topRight));
  });
  test('calculateEdgePosition too far from top right', () {
    const offset = Offset(91, 9);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin), equals(null));
  });

  // bottomRight

  test('calculateEdgePosition on bottom right', () {
    const offset = Offset(96, 96);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.bottomRight));
  });
  test('calculateEdgePosition on bottom right, further from bottom', () {
    const offset = Offset(96, 91);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.bottomRight));
  });
  test('calculateEdgePosition on bottom right, further from right', () {
    const offset = Offset(91, 96);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.bottomRight));
  });
  test('calculateEdgePosition too far from bottom right', () {
    const offset = Offset(91, 91);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin), equals(null));
  });

  // bottomLeft

  test('calculateEdgePosition on bottom left', () {
    const offset = Offset(4, 96);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.bottomLeft));
  });
  test('calculateEdgePosition on bottom left, further from bottom', () {
    const offset = Offset(4, 91);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.bottomLeft));
  });
  test('calculateEdgePosition on bottom left, further from left', () {
    const offset = Offset(9, 96);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin),
        equals(EntityEdge.bottomLeft));
  });
  test('calculateEdgePosition too far from bottom left', () {
    const offset = Offset(9, 91);
    const size = Size(100, 100);
    const double margin = 5;
    expect(calculateEdgePosition(offset, size, margin), equals(null));
  });
}
