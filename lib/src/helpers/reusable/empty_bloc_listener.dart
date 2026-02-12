import 'package:flutter_bloc/flutter_bloc.dart';

BlocListener<B, S> emptyBlocListener<B extends StateStreamable<S>, S>() {
  return BlocListener<B, S>(
    listenWhen: (previous, current) => false,
    listener: (_, _) {},
  );
}
