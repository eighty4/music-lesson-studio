import 'dart:io';

import 'package:http/http.dart' as http;

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
