import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mls_api/api_types.dart';

void main() {
  test('LessonUnit toJson without frames', () {
    final json = jsonEncode(LessonUnit(name: 'Banjo 101', frames: []));
    expect(json, equals('{"id":null,"name":"Banjo 101","frames":[]}'));
  });

  test('Frame toJson with entities', () {
    final json = jsonEncode(Frame(entities: [
      Entity(
        type: EntityType.measureChart,
        offset: const Offset(20, 20),
        size: const Size(20, 23),
      ),
      Entity(
        type: EntityType.chordChart,
        offset: const Offset(0.1234, .86),
        size: const Size(.5, .7),
      )
    ]));
    expect(
        json,
        equals(
            '{"entities":[{"type":"measure","rect":{"x":20.0,"y":20.0,"w":20.0,"h":23.0}},{"type":"chord","rect":{"x":0.1234,"y":0.86,"w":0.5,"h":0.7}}]}'));
  });

  test('Entity toJson', () {
    final json = jsonEncode(Entity(
      type: EntityType.measureChart,
      offset: const Offset(20, 20),
      size: const Size(20, 23),
    ));
    expect(
        json,
        equals(
            '{"type":"measure","rect":{"x":20.0,"y":20.0,"w":20.0,"h":23.0}}'));
  });
}
