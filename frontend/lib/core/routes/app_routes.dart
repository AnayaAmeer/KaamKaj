import 'package:flutter/material.dart';

import '../../features/splash/splash_screen.dart';
import 'route_names.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = RouteNames.splash;

  static Map<String, WidgetBuilder> routes = {
    RouteNames.splash: (_) => const SplashScreen(),
  };
}