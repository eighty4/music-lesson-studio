import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class MlsAppRoutes {
  static const splash = "/splash";
  static const login = "/login";
  static const classList = "/classes";
  static const classView = "/class/:classId";
  static const playLesson = "$classView/lesson/:lessonId";
  static const profile = "/profile";
  static const playSong = "/song/:songId";
  static const songbook = "/songbook";
}

extension MlsAppPaths on GoRouterState {
  String songId() => pathParameters['songId']!;
}

extension MlsAppRouting on BuildContext {
  void goToClasses() => go(MlsAppRoutes.classList);

  void goToLogin() => go(MlsAppRoutes.login);

  Future<String?> goToPlaySong(String songId) =>
      push(MlsAppRoutes.playSong.replaceFirst(":songId", songId));

  void goToProfile() => go(MlsAppRoutes.profile);

  void goToSongbook() => go(MlsAppRoutes.songbook);

  String get currentRoutePath =>
      GoRouter.of(this).routeInformationProvider.value.uri.path;
}
