library mls_api;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mls_api/api_types.dart';

enum _HttpMethod { get, post, put }

final _defaultClient = http.Client();

Future<LessonPlan> getLessonPlan(String apiHost, String planId,
        {http.Client? httpClient}) async =>
    LessonPlan.fromJson(await _getJson('http://$apiHost/api/lessons/$planId',
        httpClient: httpClient));

Future<(LessonPlan, LessonUnit)> getLessonUnit(
    String apiHost, String planId, String unitId,
    {http.Client? httpClient}) async {
  final decodedJson = jsonDecode(await _getJson(
      'http://$apiHost/api/lessons/$planId/units/$unitId',
      httpClient: httpClient));
  return (
    LessonPlan.fromDecodedJson(decodedJson['plan']),
    LessonUnit.fromDecodedJson(decodedJson)
  );
}

Future<String> createLessonPlan(String apiHost,
    {http.Client? httpClient}) async {
  final response = await _send(_HttpMethod.post, 'http://$apiHost/api/lessons',
      httpClient: httpClient);
  if (kDebugMode) {
    print('mls_api._createLessonPlan created ${response.body}');
  }
  return response.body;
}

Future<String> createLessonUnit(
    String apiHost, String planId, List<Frame> frames,
    {http.Client? httpClient}) async {
  final response = await _postJson(
      'http://$apiHost/api/lessons/$planId/units', LessonUnit(frames: frames),
      httpClient: httpClient);
  if (kDebugMode) {
    print('mls_api._createLessonUnit $planId created ${response.body}');
  }
  return response.body;
}

Future<void> updateLessonUnitFrames(
    String apiHost, String planId, String unitId, List<Frame> frames,
    {http.Client? httpClient}) async {
  await _putJson(
      'http://$apiHost/api/lessons/$planId/units/$unitId/frames', frames,
      httpClient: httpClient);
}

Future<http.Response> _send(_HttpMethod method, String url,
    {Map<String, String>? additionalHeaders,
    String? body,
    http.Client? httpClient}) async {
  httpClient ??= _defaultClient;
  final Map<String, String> headers = {
    HttpHeaders.cacheControlHeader: 'no-cache',
  };
  if (additionalHeaders != null) {
    headers.addAll(additionalHeaders);
  }
  final uri = Uri.parse(url);
  final response = await switch (method) {
    _HttpMethod.get => httpClient.get(uri, headers: additionalHeaders),
    _HttpMethod.post =>
      httpClient.post(uri, headers: additionalHeaders, body: body),
    _HttpMethod.put =>
      httpClient.put(uri, headers: additionalHeaders, body: body),
  };
  if (kDebugMode) {
    print(
        'mls_api._send $method $uri ${response.statusCode} ${body?.length} bytes');
  }
  if (response.statusCode < 200 || response.statusCode > 299) {
    throw Error();
  } else {
    return response;
  }
}

Future<String> _getJson(String url, {http.Client? httpClient}) async {
  final response = await _send(_HttpMethod.get, url,
      additionalHeaders: {
        HttpHeaders.acceptHeader: 'application/json; charset=UTF-8',
      },
      httpClient: httpClient);
  if (kDebugMode) {
    print('mls_api._getJson $url returned ${response.body}');
  }
  return response.body;
}

Future<http.Response> _postJson(String url, Object data,
        {http.Client? httpClient}) =>
    _sendJson(_HttpMethod.post, url, data, httpClient: httpClient);

Future<http.Response> _putJson(String url, Object data,
        {http.Client? httpClient}) =>
    _sendJson(_HttpMethod.put, url, data, httpClient: httpClient);

Future<http.Response> _sendJson(_HttpMethod method, String url, Object data,
        {http.Client? httpClient}) =>
    _send(method, url,
        body: jsonEncode(data),
        additionalHeaders: const {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        httpClient: httpClient);
