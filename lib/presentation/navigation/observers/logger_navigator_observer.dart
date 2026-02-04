import 'package:flutter/material.dart';

class LoggerNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint(
      'Navigated to ${route.settings.name}'
      '${previousRoute?.settings.name != null ? ' from ${previousRoute?.settings.name}' : ''}',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    debugPrint('Navigated back from ${route.settings.name} to ${previousRoute?.settings.name}');
  }
}
