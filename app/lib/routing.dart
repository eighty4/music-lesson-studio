import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class MlsAppRoutes {
  static const splash = "/splash";
  static const login = "/login";
  static const classList = "/classes";
  static const classView = "/class/:classId";
  static const playLesson = "$classView/lesson/:lessonId";
}

extension MlsAppRouting on BuildContext {
  goToLoginScreen() {
    go(MlsAppRoutes.login);
  }
}
