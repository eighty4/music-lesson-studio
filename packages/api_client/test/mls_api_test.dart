import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_api/api_types.dart';
import 'package:mls_api/http_client.dart';
import 'package:mls_api/mls_api.dart';
import 'package:mls_testing_create_auth_token/create_token.dart';

const apiHost = 'localhost:5173';

void main() async {
  final httpClient = MlsTokenHttpClient(await createAuthToken(jsDir: '../'));
  group('api client protocol and serde tests', () {
    test('getLessonPlan', () async {
      final planId = await createLessonPlan(apiHost, httpClient: httpClient);
      await createLessonUnit(
          apiHost,
          planId,
          [
            Frame(entities: [
              Entity.measureChart(
                  instrument: Instrument.banjo,
                  notes: [],
                  offset: const Offset(0, 0),
                  size: const Size(1, 1)),
            ]),
          ],
          httpClient: httpClient);
      final lessonPlan =
          await getLessonPlan(apiHost, planId, httpClient: httpClient);
      expect(lessonPlan.id, equals(planId));
      expect(lessonPlan.name, isNull);
      expect(lessonPlan.units.isEmpty, isTrue);
    });

    test('getLessonUnit', () async {
      final planId = await createLessonPlan(apiHost, httpClient: httpClient);
      final unitId = await createLessonUnit(
          apiHost,
          planId,
          [
            Frame(entities: [
              Entity.measureChart(
                  instrument: Instrument.banjo,
                  notes: [],
                  offset: const Offset(0, 0),
                  size: const Size(1, 1)),
            ]),
          ],
          httpClient: httpClient);
      final (lessonPlan, lessonUnit) =
          await getLessonUnit(apiHost, planId, unitId, httpClient: httpClient);
      expect(lessonPlan.id, equals(planId));
      expect(lessonPlan.name, isNull);
      expect(lessonPlan.units.isEmpty, isTrue);
      expect(lessonUnit.id, equals(unitId));
      expect(lessonUnit.name, isNull);
      expect(lessonUnit.frames, isNotNull);
      expect(lessonUnit.frames.length, equals(1));
      expect(lessonUnit.frames.length, equals(1));
      expect(lessonUnit.frames[0].entities.length, equals(1));
      expect(lessonUnit.frames[0].entities[0].type,
          equals(EntityType.measureChart));
      expect(
          lessonUnit.frames[0].entities[0].offset, equals(const Offset(0, 0)));
      expect(lessonUnit.frames[0].entities[0].size, equals(const Size(1, 1)));
    });

    test('updateLessonUnitFrames', () async {
      final planId = await createLessonPlan(apiHost, httpClient: httpClient);
      final unitId = await createLessonUnit(
          apiHost,
          planId,
          [
            Frame(entities: [
              Entity.measureChart(
                  instrument: Instrument.banjo,
                  notes: [],
                  offset: const Offset(0, 0),
                  size: const Size(1, 1)),
            ]),
          ],
          httpClient: httpClient);
      await updateLessonUnitFrames(apiHost, planId, unitId, [],
          httpClient: httpClient);
      final (_, unit) =
          await getLessonUnit(apiHost, planId, unitId, httpClient: httpClient);
      expect(unit.frames.isEmpty, isTrue);
    });
  });
}
