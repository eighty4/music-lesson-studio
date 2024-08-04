import 'dart:io' show Platform;

class MlsApiUri {
  static Uri fromPath(String path) {
    assert(path[0] == '/');
    return Uri.parse(_resolveApiHost() + path);
  }
}

String _resolveApiHost() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5173';
  } else {
    return 'http://localhost:5173';
  }
}
