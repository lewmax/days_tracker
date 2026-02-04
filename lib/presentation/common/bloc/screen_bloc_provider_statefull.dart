import 'package:days_tracker/presentation/common/bloc/bloced_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract base class ScreenBlocProviderStateful<T extends StatefulWidget, B extends BlocBase<S>, S>
    extends State<T>
    with BlocedMixin<B, S> {
  B createBloc();

  Widget buildScreen(BuildContext context);

  late final B bloc;

  @override
  void initState() {
    super.initState();
    bloc = createBloc();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<B>(create: (_) => bloc)],
      child: Builder(builder: (context) => buildScreen(context)),
    );
  }
}
