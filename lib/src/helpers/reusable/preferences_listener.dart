import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

/// A function-based listener for preferences, designed to be used
/// within a [MultiBlocListener].
///
/// This matches the pattern of [emptyBlocListener] and allows you to
/// listen to a [ValueListenable] (preference) and trigger side effects
/// (like adding events to a Bloc) without building UI.
///
/// ### Example:
/// ```dart
/// MultiBlocListener(
///   listeners: [
///     preferencesListener<AuthBloc, AuthState, String?>(
///       listenTo: prefs.authTokenNotifier,
///       listener: (context, token) {
///         context.read<AuthBloc>().add(AuthTokenChanged(token));
///       },
///     ),
///   ],
///   child: const HomeView(),
/// )
/// ```
PreferencesListener<B, S, T>
preferencesListener<B extends StateStreamable<S>, S, T>({
  required ValueListenable<T> listenTo,
  required void Function(BuildContext context, T value) listener,
  bool Function(T previous, T current)? listenWhen,
}) {
  return PreferencesListener<B, S, T>(
    listenTo: listenTo,
    listener: listener,
    listenWhen: listenWhen,
  );
}

/// Internal widget that powers [preferencesListener].
///
/// It implements [SingleChildWidget] to support nesting in [MultiBlocListener].
/// Use the [preferencesListener] helper function for a cleaner API.
class PreferencesListener<B extends StateStreamable<S>, S, T>
    extends SingleChildStatefulWidget {
  const PreferencesListener({
    super.key,
    required this.listenTo,
    required this.listener,
    this.listenWhen,
    super.child,
  });

  final ValueListenable<T> listenTo;
  final void Function(BuildContext context, T value) listener;
  final bool Function(T previous, T current)? listenWhen;

  @override
  State<PreferencesListener<B, S, T>> createState() =>
      _PreferencesListenerState<B, S, T>();
}

class _PreferencesListenerState<B extends StateStreamable<S>, S, T>
    extends SingleChildState<PreferencesListener<B, S, T>> {
  T? _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.listenTo.value;
    widget.listenTo.addListener(_handleUpdate);
  }

  @override
  void didUpdateWidget(PreferencesListener<B, S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenTo != widget.listenTo) {
      oldWidget.listenTo.removeListener(_handleUpdate);
      _previousValue = widget.listenTo.value;
      widget.listenTo.addListener(_handleUpdate);
    }
  }

  @override
  void dispose() {
    widget.listenTo.removeListener(_handleUpdate);
    super.dispose();
  }

  void _handleUpdate() {
    final currentValue = widget.listenTo.value;
    final previousValue = _previousValue as T;

    if (widget.listenWhen?.call(previousValue, currentValue) ?? true) {
      widget.listener(context, currentValue);
    }
    _previousValue = currentValue;
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child ?? const SizedBox.shrink();
  }
}
