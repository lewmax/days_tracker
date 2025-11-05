import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: HomeRoute.page,
          initial: true,
          children: [
            AutoRoute(page: VisitsRoute.page, initial: true),
            AutoRoute(page: SummaryRoute.page),
            AutoRoute(page: MapRoute.page),
            AutoRoute(page: SettingsRoute.page),
          ],
        ),
      ];
}
