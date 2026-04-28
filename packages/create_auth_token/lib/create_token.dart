library;

import 'dart:io';

Future<String> createAuthToken({required String jsDir}) async {
  final jsPath = [jsDir, 'create_auth_token'].join(Platform.pathSeparator);
  // todo check if jsDir correctly points to create_auth_token
  final p = await Process.run('pnpm', [
    'exec',
    'tsx',
    'create_auth_token.ts',
  ], workingDirectory: jsPath);
  if (p.exitCode == 0) {
    return p.stdout.toString().trim();
  } else {
    throw StateError(
      'create_auth_token.ts non-zero exit: ${p.stderr.toString()}',
    );
  }
}
