import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'login.dart';
import 'routing.dart';
import 'splash.dart';

void main() {
  runApp(const MlsApp());
}

class MlsApp extends StatelessWidget {
  const MlsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(initialLocation: '/splash', routes: [
        GoRoute(
          path: MlsAppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: MlsAppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
      ]),
    );
  }
}
