import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainNav = '/main';
  static const String profile = '/profile';

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: splash,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final isLoggingIn = state.matchedLocation == login ||
            state.matchedLocation == register ||
            state.matchedLocation == splash;

        // AUTH GATEWAY: Nếu chưa đăng nhập mà cố vào main/profile -> Chuyển về login
        if (authState is Unauthenticated) {
          return isLoggingIn ? null : login;
        }

        // Nếu đã đăng nhập mà đang ở trang login/register/splash -> Chuyển vào mainNav
        if (authState is Authenticated) {
          if (isLoggingIn && state.matchedLocation != splash) {
            return mainNav;
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: mainNav,
          builder: (context, state) => const MainNavigationPage(),
        ),
        GoRoute(
          path: profile,
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
