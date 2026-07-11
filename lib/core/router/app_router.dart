import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login  = '/login';
  static const String register = '/register';
  static const String home   = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      // TODO: Add login, register, home routes as screens are built
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
