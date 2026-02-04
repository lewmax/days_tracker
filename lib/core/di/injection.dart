import 'package:days_tracker/core/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// Global GetIt instance for dependency injection.
final GetIt locator = GetIt.instance;

@InjectableInit(initializerName: r'$configure', preferRelativeImports: true, asExtension: false)
Future<GetIt> configureDependencies({String? environment}) =>
    $configure(locator, environment: environment);
