import 'package:days_tracker/presentation/common/bloc/bloced_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlocedState<T extends StatefulWidget, B extends BlocBase<S>, S> extends State<T>
    with BlocedMixin<B, S> {
  late final B bloc;

  @override
  void initState() {
    super.initState();
    bloc = blocOf(context);
  }
}
