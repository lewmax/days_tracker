import 'dart:math' as math;

import 'package:days_tracker/core/di/injection.dart';
import 'package:days_tracker/core/utils/extensions/context_extensions.dart';
import 'package:days_tracker/l10n/s.dart';
import 'package:days_tracker/presentation/common/bloc/app_bloc_observer.dart';
import 'package:days_tracker/presentation/navigation/app_router.dart';
import 'package:days_tracker/presentation/navigation/observers/logger_navigator_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';

/// Application entry point.
///
/// Initializes dependency injection and runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();

  Bloc.observer = const AppBlocObserver();

  // Initialize dependency injection
  logger.d('Initializing dependency injection');
  final getIt = await configureDependencies();
  logger.d('Dependency injection initialized');

  logger.d('Initializing app router');
  final appRouter = getIt<AppRouter>();
  logger.d('App router initialized');

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(DaysTrackerApp(appRouter: appRouter));
}

const _maxTextScaleFactor = 1.2;

/// Root widget for the DaysTracker application.
class DaysTrackerApp extends StatelessWidget {
  const DaysTrackerApp({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DaysTracker',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      locale: const Locale('en'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      routerConfig: appRouter.config(navigatorObservers: () => [LoggerNavigatorObserver()]),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final limitedTextScaleFactor =
            // ignore: deprecated_member_use
            math.min(mediaQuery.textScaleFactor, _maxTextScaleFactor);

        return MediaQuery(
          // ignore: deprecated_member_use
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(limitedTextScaleFactor)),
          child: GestureDetector(
            // onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: child ?? const SizedBox(),
          ),
        );
      },
    );
  }
}
