import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base stateful widget that provides BLoC
abstract class BlocedState<W extends StatefulWidget,
    B extends BlocBase<dynamic>> extends State<W> {
  late B bloc;

  B createBloc(BuildContext context);

  @override
  void initState() {
    super.initState();
    bloc = createBloc(context);
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: (_) => bloc,
      child: buildWidget(context),
    );
  }

  Widget buildWidget(BuildContext context);
}
