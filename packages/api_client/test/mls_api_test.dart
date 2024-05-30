import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mls_api/api_types.dart';
import 'package:mls_api/mls_api.dart';
import 'package:mls_testing_create_auth_token/create_token.dart';

class MlsTokenHttpClient extends http.BaseClient {
  final String mlsToken;
  final http.Client httpClient = http.Client();

  MlsTokenHttpClient(this.mlsToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $mlsToken';
    return httpClient.send(request);
  }
}

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
              Entity(
                  type: EntityType.measureChart,
                  offset: const Offset(40, 60),
                  size: const Size(50, 80)),
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
              Entity(
                  type: EntityType.measureChart,
                  offset: const Offset(40, 60),
                  size: const Size(50, 80)),
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
      expect(lessonUnit.frames[0].entities[0].offset,
          equals(const Offset(40, 60)));
      expect(lessonUnit.frames[0].entities[0].size, equals(const Size(50, 80)));
    });

    test('updateLessonUnitFrames', () async {
      final planId = await createLessonPlan(apiHost, httpClient: httpClient);
      final unitId = await createLessonUnit(
          apiHost,
          planId,
          [
            Frame(entities: [
              Entity(
                  type: EntityType.measureChart,
                  offset: const Offset(40, 60),
                  size: const Size(50, 80)),
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
