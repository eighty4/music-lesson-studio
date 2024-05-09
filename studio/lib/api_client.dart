import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_types.dart';
import 'editor_session.dart';

enum HttpMethod { post, put }

class ApiClient {
  static final httpClient = http.Client();

  static Future<void> saveLessonUnitFrames(
      EditorSession session, List<Frame> frames) async {
    final planId = session.planId ?? await _createLessonPlan(session);
    final unitId = session.unitId;
    if (unitId == null) {
      await _createLessonUnit(session, planId, frames);
    } else {
      await _updateLessonUnitFrames(session.apiHost, planId, unitId, frames);
    }
  }

  static Future<String> _createLessonPlan(EditorSession session) async {
    final url = 'http://${session.apiHost}/api/lessons';
    final response = await _postJson(url, {});
    EditorSession.update(session, planId: response.body);
    return response.body;
  }

  static Future<void> _createLessonUnit(
      EditorSession session, String planId, List<Frame> frames) async {
    final url = 'http://${session.apiHost}/api/lessons/$planId/units';
    final response =
        await _postJson(url, LessonUnit(name: 'Something', frames: frames));
    EditorSession.update(session, unitId: response.body);
  }

  static Future<void> _updateLessonUnitFrames(
      String apiHost, String planId, String unitId, List<Frame> frames) async {
    final url = 'http://$apiHost/api/lessons/$planId/units/$unitId/frames';
    await _putJson(url, frames);
  }

  static Future<http.Response> _sendJson(
      HttpMethod method, String url, Object data) async {
    const headers = {
      HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8"
    };
    final body = jsonEncode(data);
    final uri = Uri.parse(url);
    final response = await switch (method) {
      HttpMethod.post => httpClient.post(uri, headers: headers, body: body),
      HttpMethod.put => httpClient.put(uri, headers: headers, body: body),
    };
    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Error();
    } else {
      return response;
    }
  }

  static Future<http.Response> _postJson(String url, Object data) =>
      _sendJson(HttpMethod.post, url, data);

  static Future<http.Response> _putJson(String url, Object data) =>
      _sendJson(HttpMethod.put, url, data);
}
