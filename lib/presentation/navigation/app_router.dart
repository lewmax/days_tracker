import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/presentation/screens/main_shell_screen.dart';
import 'package:days_tracker/presentation/screens/settings/settings_screen.dart';
import 'package:days_tracker/presentation/screens/statistics/statistics_screen.dart';
import 'package:days_tracker/presentation/screens/visits/add_visit_screen.dart';
import 'package:days_tracker/presentation/screens/visits/edit_visit_screen.dart';
import 'package:days_tracker/presentation/screens/visits/visit_details_screen.dart';
import 'package:days_tracker/presentation/screens/visits/visits_screen.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

part 'app_router.gr.dart';

/// Main application router using AutoRoute.
@Singleton()
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainShellRoute.page,
      initial: true,
      children: [
        AutoRoute(page: VisitsRoute.page, path: 'visits', initial: true),
        AutoRoute(page: StatisticsRoute.page, path: 'statistics'),
        AutoRoute(page: SettingsRoute.page, path: 'settings'),
      ],
    ),
    AutoRoute(page: AddVisitRoute.page, path: '/visits/add'),
    AutoRoute(page: EditVisitRoute.page, path: '/visits/:id/edit'),
    AutoRoute(page: VisitDetailsRoute.page, path: '/visits/:id'),
  ];
}
