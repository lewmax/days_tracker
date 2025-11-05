import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base widget that provides BLoC
abstract class BlocedWidget<B extends BlocBase<dynamic>>
    extends StatelessWidget {
  const BlocedWidget({super.key});

  B createBloc(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: createBloc,
      child: buildWidget(context),
    );
  }

  Widget buildWidget(BuildContext context);
}
