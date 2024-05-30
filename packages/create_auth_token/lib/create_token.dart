library mls_testing_create_auth_token;

import 'dart:io';

Future<String> createAuthToken({required String jsDir}) async {
  final jsPath = [jsDir, 'create_auth_token'].join(Platform.pathSeparator);
  // todo check if jsDir correctly points to create_auth_token
  String? error;
  try {
    final p = await Process.run('node', ['create_auth_token.js'],
        workingDirectory: jsPath);
    if (p.exitCode == 0) {
      return p.stdout.toString().trim();
    } else {
      error = p.stderr.toString();
    }
  } catch (e) {
    error = e.toString();
  }
  print('error running create_auth_token.js: $error');
  exit(1);
}
