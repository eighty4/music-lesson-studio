library mls_api;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mls_api/api_types.dart';

enum _HttpMethod { post, put }

class Api {
  static final _httpClient = http.Client();

  static Future<String> createLessonPlan(String apiHost,
      {http.Client? httpClient}) async {
    final response = await _send(
        _HttpMethod.post, 'http://$apiHost/api/lessons',
        httpClient: httpClient);
    if (kDebugMode) {
      print('ApiClient._createLessonPlan created ${response.body}');
    }
    return response.body;
  }

  static Future<String> createLessonUnit(
      String apiHost, String planId, List<Frame> frames,
      {http.Client? httpClient}) async {
    final response = await _postJson(
        'http://$apiHost/api/lessons/$planId/units', LessonUnit(frames: frames),
        httpClient: httpClient);
    if (kDebugMode) {
      print('ApiClient._createLessonUnit $planId created ${response.body}');
    }
    return response.body;
  }

  static Future<void> updateLessonUnitFrames(
      String apiHost, String planId, String unitId, List<Frame> frames,
      {http.Client? httpClient}) async {
    await _putJson(
        'http://$apiHost/api/lessons/$planId/units/$unitId/frames', frames,
        httpClient: httpClient);
  }

  static Future<http.Response> _send(_HttpMethod method, String url,
      {Map<String, String>? additionalHeaders,
      String? body,
      http.Client? httpClient}) async {
    httpClient ??= _httpClient;
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

  static Future<http.Response> _postJson(String url, Object data,
          {http.Client? httpClient}) =>
      _sendJson(_HttpMethod.post, url, data, httpClient: httpClient);

  static Future<http.Response> _putJson(String url, Object data,
          {http.Client? httpClient}) =>
      _sendJson(_HttpMethod.put, url, data, httpClient: httpClient);

  static Future<http.Response> _sendJson(
          _HttpMethod method, String url, Object data,
          {http.Client? httpClient}) =>
      _send(method, url,
          body: jsonEncode(data),
          additionalHeaders: const {
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          },
          httpClient: httpClient);
}

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
