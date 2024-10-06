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

extension MlsAppRouting on BuildContext {
  goToClasses() => go(MlsAppRoutes.classList);

  goToLogin() => go(MlsAppRoutes.login);

  goToProfile() => go(MlsAppRoutes.profile);

  goToSongbook() => go(MlsAppRoutes.songbook);

  String get currentRoutePath =>
      GoRouter.of(this).routeInformationProvider.value.uri.path;
}
