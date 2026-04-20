import '../../core/router/app_routes.dart';

enum DefaultLanding {
  home,
  log;

  String get path => switch (this) {
        DefaultLanding.home => AppRoutes.home,
        DefaultLanding.log => AppRoutes.log,
      };
}
