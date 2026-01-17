import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_api/api_types.dart';
import 'package:mls_api/http_client.dart';
import 'package:mls_api/mls_api.dart' as api;
import 'package:mls_studio/editor_session.dart';
import 'package:mls_testing_create_auth_token/create_token.dart';

void main() async {
  const apiHost = 'localhost:5173';
  final httpClient = MlsTokenHttpClient(
    await createAuthToken(jsDir: '../packages'),
  );
  group('refreshLessonData', () {
    test('noop for new lesson', () async {
      final session = EditorSession.fromSessionParams(
        apiClient: httpClient,
        apiHost: apiHost,
      );
      final result = await session.refreshLessonData();
      expect(result.apiHost, equals(session.apiHost));
      expect(result.plan, isNull);
      expect(result.unit, isNull);
    });
    test('retrieves lesson plan', () async {
      // todo creating lesson plan with name
      final planId = await api.createLessonPlan(
        apiHost,
        httpClient: httpClient,
      );
      final session = EditorSession.fromSessionParams(
        apiClient: httpClient,
        apiHost: apiHost,
        planId: planId,
      );
      final result = await session.refreshLessonData();
      expect(result.apiHost, equals(session.apiHost));
      expect(result.plan, isNotNull);
      expect(result.plan?.id, equals(planId));
      // todo retrieving lesson plan with instrument
      // expect(result.plan?.instrument, isNotNull);
      // todo retrieving lesson plan with name
      // expect(result.plan?.name, isNotNull);
      expect(result.plan?.name, isNull);
      expect(result.plan?.units, isNotNull);
      expect(result.plan?.units, isEmpty);
      expect(result.unit, isNull);
    });
    test('retrieves lesson unit without frames', () async {
      final planId = await api.createLessonPlan(
        apiHost,
        httpClient: httpClient,
      );
      // todo creating lesson unit with name
      final unitId = await api.createLessonUnit(
        apiHost,
        planId,
        [],
        httpClient: httpClient,
      );
      final session = EditorSession.fromSessionParams(
        apiClient: httpClient,
        apiHost: apiHost,
        planId: planId,
        unitId: unitId,
      );
      final result = await session.refreshLessonData();
      expect(result.apiHost, equals(session.apiHost));
      expect(result.plan, isNotNull);
      expect(result.plan?.id, equals(planId));
      expect(result.plan?.name, isNull);
      expect(result.unit, isNotNull);
      expect(result.unit?.id, equals(unitId));
      // todo retrieving lesson plan with name
      // expect(result.unit?.name, isNotNull);
      expect(result.unit?.name, isNull);
      expect(result.unit?.frames.isEmpty, isTrue);
    });
    test('retrieves lesson unit with frames', () async {
      final planId = await api.createLessonPlan(
        apiHost,
        httpClient: httpClient,
      );
      // todo creating lesson unit with name
      final List<Frame> frames = [
        Frame(
          entities: [
            Entity.chordChart(
              chord: Chord.c,
              instrument: Instrument.banjo,
              offset: const Offset(.5, .5),
              size: const Size(.2, .2),
            ),
          ],
        ),
        Frame(
          entities: [
            Entity.measureChart(
              notes: [],
              instrument: Instrument.banjo,
              offset: const Offset(.8, .8),
              size: const Size(.3, .3),
            ),
          ],
        ),
      ];
      final unitId = await api.createLessonUnit(
        apiHost,
        planId,
        frames,
        httpClient: httpClient,
      );
      final session = EditorSession.fromSessionParams(
        apiClient: httpClient,
        apiHost: apiHost,
        planId: planId,
        unitId: unitId,
      );
      final result = await session.refreshLessonData();
      expect(result.apiHost, equals(session.apiHost));
      expect(result.plan, isNotNull);
      expect(result.plan?.id, equals(planId));
      expect(result.plan?.name, isNull);
      expect(result.unit, isNotNull);
      expect(result.unit?.id, equals(unitId));
      expect(result.unit?.name, isNull);
      expect(result.unit?.frames.length, equals(2));
      expect(
        result.unit?.frames[0].entities[0].type,
        equals(EntityType.chordChart),
      );
      expect(
        result.unit?.frames[0].entities[0].offset,
        equals(frames[0].entities[0].offset),
      );
      expect(
        result.unit?.frames[0].entities[0].size,
        equals(frames[0].entities[0].size),
      );
      expect(
        result.unit?.frames[1].entities[0].type,
        equals(EntityType.measureChart),
      );
      expect(
        result.unit?.frames[1].entities[0].offset,
        equals(frames[1].entities[0].offset),
      );
      expect(
        result.unit?.frames[1].entities[0].size,
        equals(frames[1].entities[0].size),
      );
    });
  });
  group('saveLessonUnitFrames', () {
    test('creates plan and unit for new lesson', () async {
      final List<Frame> frames = [
        Frame(
          entities: [
            Entity.chordChart(
              chord: Chord.c,
              instrument: Instrument.banjo,
              offset: const Offset(.5, .5),
              size: const Size(.2, .2),
            ),
          ],
        ),
      ];
      final session = EditorSession.fromSessionParams(
        apiClient: httpClient,
        apiHost: apiHost,
      );
      final result = await session.saveLessonUnitFrames(frames);
      expect(result.plan?.id, isNotNull);
      expect(result.unit?.id, isNotNull);
    });
    test('creates unit for new lesson of existing plan', () async {
      final List<Frame> frames = [
        Frame(
          entities: [
            Entity.chordChart(
              chord: Chord.c,
              instrument: Instrument.banjo,
              offset: const Offset(.5, .5),
              size: const Size(.2, .2),
            ),
          ],
        ),
      ];
      final planId = await api.createLessonPlan(
        apiHost,
        httpClient: httpClient,
      );
      final session = EditorSession.fromSessionParams(
        apiClient: httpClient,
        apiHost: apiHost,
        planId: planId,
      );
      final result = await session.saveLessonUnitFrames(frames);
      expect(result.plan?.id, equals(session.plan?.id));
      expect(result.unit?.id, isNotNull);
      expect(result.unit?.frames.length, equals(1));
      final fetched = await api.getLessonUnit(
        apiHost,
        planId,
        result.unit!.id!,
        httpClient: httpClient,
      );
      expect(fetched.$1.id, equals(planId));
      expect(fetched.$2.frames.length, equals(1));
      expect(fetched.$2.frames[0].entities.length, equals(1));
      expect(
        fetched.$2.frames[0].entities[0].type,
        equals(EntityType.chordChart),
      );
      expect(
        fetched.$2.frames[0].entities[0].offset,
        equals(const Offset(.5, .5)),
      );
      expect(fetched.$2.frames[0].entities[0].size, equals(const Size(.2, .2)));
    });
    test('updates frame data of existing lesson', () async {
      final planId = await api.createLessonPlan(
        apiHost,
        httpClient: httpClient,
      );
      final frames = [
        Frame(
          entities: [
            Entity.chordChart(
              chord: Chord.c,
              instrument: Instrument.banjo,
              offset: const Offset(.5, .5),
              size: const Size(.2, .2),
            ),
          ],
        ),
      ];
      final unitId = await api.createLessonUnit(
        apiHost,
        planId,
        frames,
        httpClient: httpClient,
      );
      final session = EditorSession.fromSessionParams(
        apiClient: httpClient,
        apiHost: apiHost,
        planId: planId,
        unitId: unitId,
      );
      final result = await session.saveLessonUnitFrames([
        ...frames,
        Frame(
          entities: [
            Entity.chordChart(
              chord: Chord.c,
              instrument: Instrument.banjo,
              offset: const Offset(.5, .5),
              size: const Size(.2, .2),
            ),
          ],
        ),
      ]);
      expect(result.unit?.frames.length, equals(2));
      final fetched = await api.getLessonUnit(
        apiHost,
        planId,
        result.unit!.id!,
        httpClient: httpClient,
      );
      expect(fetched.$2.frames.length, equals(2));
    });
    test('updates frame data of new lesson', () async {
      final planId = await api.createLessonPlan(
        apiHost,
        httpClient: httpClient,
      );
      final session = EditorSession.fromSessionParams(
        apiClient: httpClient,
        apiHost: apiHost,
        planId: planId,
      );
      final result1 = await session.saveLessonUnitFrames([
        Frame(
          entities: [
            Entity.chordChart(
              chord: Chord.c,
              instrument: Instrument.banjo,
              offset: const Offset(.5, .5),
              size: const Size(.2, .2),
            ),
          ],
        ),
      ]);
      final result2 = await result1.saveLessonUnitFrames([
        ...result1.unit!.frames,
        Frame(
          entities: [
            Entity.chordChart(
              chord: Chord.c,
              instrument: Instrument.banjo,
              offset: const Offset(.5, .5),
              size: const Size(.2, .2),
            ),
          ],
        ),
      ]);
      expect(result2.unit?.frames.length, equals(2));
      final fetched = await api.getLessonUnit(
        apiHost,
        planId,
        result2.unit!.id!,
        httpClient: httpClient,
      );
      expect(fetched.$2.frames.length, equals(2));
    });
  });
}
