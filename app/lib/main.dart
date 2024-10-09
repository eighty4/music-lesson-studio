import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'classes.dart';
import 'login.dart';
import 'navigator.dart';
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
