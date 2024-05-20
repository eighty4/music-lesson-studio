import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mls_api/api_types.dart';

import 'editor_session.dart';

enum _HttpMethod { post, put }

class ApiClient {
  static final _httpClient = http.Client();

  // static Future<LessonPlan> getLessonPlan(EditorSession session) async {
  //   assert(session.planId != null && session.unitId != null);
  //   final planId = session.planId;
  //   final url = 'http://${session.apiHost}/api/lessons/$planId';
  //   final json = await _getJson(url);
  //   return jsonDecode(json);
  // }

  // static Future<String> _getJson(String url) async {
  //   const headers = {
  //     HttpHeaders.acceptHeader: 'application/json; charset=UTF-8',
  //   };
  //   final uri = Uri.parse(url);
  //   final response = await _httpClient.get(uri, headers: headers);
  //   if (response.statusCode < 200 || response.statusCode > 299) {
  //     throw Error();
  //   } else {
  //     return response.toString();
  //   }
  // }

  // static Future<LessonUnit> getLessonUnit(EditorSession session) async {
  //   assert(session.planId != null && session.unitId != null);
  //   final url = 'http://${session.apiHost}/api/lessons';
  //   final json = await _getJson(url);
  //   return jsonDecode(json);
  // }

  static Future<void> saveLessonUnitFrames(
      EditorSession session, List<Frame> frames) async {
    final planId = session.planId ?? await _createLessonPlan(session.apiHost);
    final unitId = session.unitId ??
        await _createLessonUnit(session.apiHost, planId, frames);
    if (session.planId == null || session.unitId == null) {
      EditorSession.update(session, planId: planId, unitId: unitId);
    } else {
      await _updateLessonUnitFrames(session.apiHost, planId, unitId, frames);
    }
  }

  static Future<String> _createLessonPlan(String apiHost) async {
    final response =
        await _send(_HttpMethod.post, 'http://$apiHost/api/lessons');
    if (kDebugMode) {
      print('ApiClient._createLessonPlan created ${response.body}');
    }
    return response.body;
  }

  static Future<String> _createLessonUnit(
      String apiHost, String planId, List<Frame> frames) async {
    final response = await _postJson(
        'http://$apiHost/api/lessons/$planId/units',
        LessonUnit(frames: frames));
    if (kDebugMode) {
      print('ApiClient._createLessonUnit $planId created ${response.body}');
    }
    return response.body;
  }

  static Future<void> _updateLessonUnitFrames(
      String apiHost, String planId, String unitId, List<Frame> frames) async {
    await _putJson(
        'http://$apiHost/api/lessons/$planId/units/$unitId/frames', frames);
  }

  static Future<http.Response> _send(_HttpMethod method, String url,
      {Map<String, String>? additionalHeaders, String? body}) async {
    final Map<String, String> headers = {
      HttpHeaders.cacheControlHeader: 'no-cache',
    };
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    final uri = Uri.parse(url);
    final response = await switch (method) {
      _HttpMethod.post =>
        _httpClient.post(uri, headers: additionalHeaders, body: body),
      _HttpMethod.put =>
        _httpClient.put(uri, headers: additionalHeaders, body: body),
    };
    if (kDebugMode) {
      print(
          'ApiClient._send $method $uri ${response.statusCode} ${body?.length} bytes');
    }
    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Error();
    } else {
      return response;
    }
  }

  static Future<http.Response> _postJson(String url, Object data) =>
      _sendJson(_HttpMethod.post, url, data);

  static Future<http.Response> _putJson(String url, Object data) =>
      _sendJson(_HttpMethod.put, url, data);

  static Future<http.Response> _sendJson(
          _HttpMethod method, String url, Object data) =>
      _send(method, url, body: jsonEncode(data), additionalHeaders: const {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      });
}
