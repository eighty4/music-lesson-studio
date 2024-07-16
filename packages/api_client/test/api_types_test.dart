import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_api/api_types.dart';

void main() {
  group('LessonPlan', () {
    group('fromJson', () {
      test('with real world json', () {
        final plan = LessonPlan.fromJson(
            '{"user":{"id":"c71524df-105b-44bf-8118-5f3a3194b174"},"id":"a7448978-cd15-41e6-b8a3-f0995a78f8d8","name":null,"instrument":null,"created":"2024-05-24T23:23:01.534Z","updated":"2024-05-24T23:23:01.534Z"}');
        expect(plan.id, equals('a7448978-cd15-41e6-b8a3-f0995a78f8d8'));
        expect(plan.name, isNull);
      });
      test('with null units', () {
        const json = """
    {
      "id": "1234",
      "name": "Banjo 101"
    }""";
        final plan = LessonPlan.fromJson(json);
        expect(plan.id, equals("1234"));
        expect(plan.name, equals("Banjo 101"));
        expect(plan.units, equals([]));
      });
      test('with empty units', () {
        const json = """
    {
      "id": "1234",
      "name": "Banjo 101",
      "units": []
    }""";
        final plan = LessonPlan.fromJson(json);
        expect(plan.id, equals("1234"));
        expect(plan.name, equals("Banjo 101"));
        expect(plan.units, equals([]));
      });

      test('with units', () {
        const json = """
    {
      "id": "1234",
      "name": "Banjo 101",
      "units": [{
        "id": "5",
        "name": "Slip slip slidin' away my index finger"
      },{
        "id": "6",
        "name": "Nine pound hammer on",
        "frames": []
      },{
        "id": "7",
        "name": "Push and pull off",
        "frames": [{
          "entities": []
        }]
      }]
    }""";
        final plan = LessonPlan.fromJson(json);
        expect(plan.id, equals('1234'));
        expect(plan.name, equals('Banjo 101'));
        expect(plan.units.length, equals(3));
        expect(plan.units[0].id, equals('5'));
        expect(plan.units[0].name,
            equals('Slip slip slidin\' away my index finger'));
        expect(plan.units[1].id, equals('6'));
        expect(plan.units[1].name, equals('Nine pound hammer on'));
        expect(plan.units[2].id, equals('7'));
        expect(plan.units[2].name, equals('Push and pull off'));
      });

      test('with entities', () {
        const json = """
    {
      "id": "1234",
      "name": "Banjo 101",
      "units": [{
        "id": "7",
        "name": "Notes of oak and melody",
        "frames": [{
          "entities": [{
            "type": "chord",
            "rect": {
              "x": 20, "y": 15, "w": 30, "h": 10
            },
            "data":{
              "chord": "c",
              "instrument": "guitar"
            }
          }]
        }]
      }]
    }""";
        final plan = LessonPlan.fromJson(json);
        expect(plan.units[0].frames, isNotNull);
        final entity = plan.units[0].frames[0].entities[0];
        expect(entity.type, equals(EntityType.chordChart));
        expect((entity.data as ChordChartData).chord, equals(Chord.c));
        expect((entity.data as ChordChartData).instrument,
            equals(Instrument.guitar));
        expect(entity.offset, equals(const Offset(20, 15)));
        expect(entity.size, equals(const Size(30, 10)));
      });
    });
  });

  group('LessonUnit', () {
    group('toJson', () {
      test('without frames', () {
        final json = jsonEncode(LessonUnit(name: 'Banjo 101', frames: []));
        expect(json, equals('{"id":null,"name":"Banjo 101","frames":[]}'));
      });
    });
  });

  group('Frame', () {
    group('toJson', () {
      test('with entities', () {
        final json = jsonEncode(Frame(entities: [
          Entity.measureChart(
            instrument: Instrument.banjo,
            notes: [],
            offset: const Offset(20, 20),
            size: const Size(20, 23),
          ),
          Entity.measureChart(
            instrument: Instrument.banjo,
            notes: [],
            offset: const Offset(0.1234, .86),
            size: const Size(.5, .7),
          )
        ]));
        expect(
            json,
            equals(
                '{"entities":[{"type":"measure","rect":{"x":20.0,"y":20.0,"w":20.0,"h":23.0},"data":{"instrument":"banjo","notes":[]}},{"type":"measure","rect":{"x":0.1234,"y":0.86,"w":0.5,"h":0.7},"data":{"instrument":"banjo","notes":[]}}]}'));
      });
    });
  });

  group('Entity', () {
    group('toJson', () {
      test('EntityType.chord', () {
        final json = jsonEncode(Entity.chordChart(
          chord: Chord.c,
          instrument: Instrument.banjo,
          offset: const Offset(20, 20),
          size: const Size(20, 23),
        ));
        expect(
            json,
            equals(
                '{"type":"chord","rect":{"x":20.0,"y":20.0,"w":20.0,"h":23.0},"data":{"chord":"c","instrument":"banjo"}}'));
      });
      test('EntityType.measure with a note', () {
        final json = jsonEncode(Entity.measureChart(
          instrument: Instrument.guitar,
          notes: [
            Note(1, 2, timing: const Timing(NoteType.eighth, 3), melody: true)
          ],
          offset: const Offset(20, 20),
          size: const Size(20, 23),
        ));
        expect(
            json,
            equals(
                '{"type":"measure","rect":{"x":20.0,"y":20.0,"w":20.0,"h":23.0},"data":{"instrument":"guitar","notes":[{"f":2,"m":true,"s":1,"t":5}]}}'));
      });
      test('EntityType.measure without notes', () {
        final json = jsonEncode(Entity.measureChart(
          instrument: Instrument.guitar,
          notes: [],
          offset: const Offset(20, 20),
          size: const Size(20, 23),
        ));
        expect(
            json,
            equals(
                '{"type":"measure","rect":{"x":20.0,"y":20.0,"w":20.0,"h":23.0},"data":{"instrument":"guitar","notes":[]}}'));
      });
    });
  });
}
