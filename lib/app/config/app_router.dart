import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainNav = '/main';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('FinSmart AI - Splash Screen'),
          ),
        ),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Login Screen'),
          ),
        ),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Register Screen'),
          ),
        ),
      ),
      GoRoute(
        path: mainNav,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Main Navigation Screen'),
          ),
        ),
      ),
    ],
  );
}
