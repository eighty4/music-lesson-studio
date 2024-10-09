import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'classes.dart';
import 'login.dart';
import 'navigator.dart';
import 'play.dart';
import 'profile.dart';
import 'routing.dart';
import 'session.dart';
import 'songbook.dart';
import 'splash.dart';

void main() {
  runApp(const MlsApp());
}

class MlsApp extends StatelessWidget {
  const MlsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(initialLocation: MlsAppRoutes.splash, routes: [
        ShellRoute(
            builder: (context, state, child) {
              return Scaffold(
                  body: SafeArea(child: SessionLookup(child: child)));
            },
            routes: [
              GoRoute(
                path: MlsAppRoutes.login,
                builder: (context, state) =>
                    const _ScreenContainer(LoginScreen()),
              ),
              GoRoute(
                path: MlsAppRoutes.splash,
                builder: (context, state) =>
                    const _ScreenContainer(SplashScreen()),
              ),
              ShellRoute(
                  builder: (context, state, child) {
                    return Column(
                      children: [
                        Expanded(child: child),
                        const NavigatorMenu(),
                      ],
                    );
                  },
                  routes: [
                    GoRoute(
                      path: MlsAppRoutes.classList,
                      builder: (context, state) =>
                          const _ScreenContainer(ClassListScreen()),
                    ),
                    _PlayInterfaceRoute(
                      path: MlsAppRoutes.playSong,
                      builder: (context, state) => _ScreenContainer(
                          PlaySongScreen(songId: state.songId())),
                    ),
                    GoRoute(
                      path: MlsAppRoutes.profile,
                      builder: (context, state) =>
                          const _ScreenContainer(ProfileScreen()),
                    ),
                    GoRoute(
                      path: MlsAppRoutes.songbook,
                      builder: (context, state) =>
                          const _ScreenContainer(SongbookScreen()),
                    ),
                  ]),
            ]),
      ]),
    );
  }
}

class _PlayInterfaceRoute extends GoRoute {
  _PlayInterfaceRoute._(
      {required super.path, required super.builder, required super.onExit});

  factory _PlayInterfaceRoute(
      {required String path, required GoRouterWidgetBuilder builder}) {
    return _PlayInterfaceRoute._(
        path: path,
        builder: (context, state) => _BeforeRoute(
            callback: requestLandscape, child: builder(context, state)),
        onExit: resetOrientation);
  }
}

class _BeforeRoute extends StatefulWidget {
  final VoidCallback callback;
  final Widget child;

  const _BeforeRoute({required this.callback, required this.child});

  @override
  State<StatefulWidget> createState() => _BeforeRouteState();
}

class _BeforeRouteState extends State<_BeforeRoute> {
  @override
  void initState() {
    super.initState();
    widget.callback();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _ScreenContainer extends StatelessWidget {
  final Widget child;

  const _ScreenContainer(this.child);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }
}

requestLandscape() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

bool resetOrientation(context, state) {
  SystemChrome.setPreferredOrientations([]);
  return true;
}
