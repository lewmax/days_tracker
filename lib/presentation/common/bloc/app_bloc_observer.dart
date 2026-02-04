import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    final states = change.toString().split('{').last.trim().split('}').first.trim();
    debugPrint('--- ${bloc.runtimeType} onChange ---');
    debugPrint(states);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('--- ${bloc.runtimeType} onError ---');
    debugPrint('$error, $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
