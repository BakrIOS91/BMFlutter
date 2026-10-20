import 'package:flutter/material.dart';

import '../view_state.dart';

/// How [WithViewState] shows an error state.
enum ErrorDisplayMode {
  /// Replace the content with the error view (default).
  replace,

  /// Show the error in a bottom sheet and keep the content visible.
  bottomSheet,
}

/// Builds a custom error view for [state]. Return `null` to use the default.
typedef ViewStateErrorBuilder = Widget? Function(
  BuildContext context,
  ViewState state,
  VoidCallback retry,
);

/// Extracts a human-readable message from a state's `errorModel`.
typedef ErrorMessageResolver = String? Function(dynamic errorModel);

/// Texts used by the default error views of [WithViewState]. Override any of
/// them to localise the screen.
class ViewStateTexts {
  const ViewStateTexts({
    this.retry = 'Retry',
    this.noNetworkTitle = 'No connection',
    this.noNetworkMessage = 'Check your connection and try again.',
    this.noDataTitle = 'Nothing here yet',
    this.noDataMessage = 'There is nothing to show.',
    this.errorTitle = 'Something went wrong',
    this.errorMessage = 'Please try again.',
    this.unauthorizedTitle = 'Session expired',
    this.unauthorizedMessage = 'Please sign in again.',
    this.signIn = 'Sign in',
    this.updateTitle = 'Update required',
    this.updateMessage = 'Please update the app to continue.',
    this.update = 'Update',
    this.unsupportedTitle = 'Unsupported device',
    this.unsupportedMessage = 'This device is not supported.',
  });

  final String retry;
  final String noNetworkTitle;
  final String noNetworkMessage;
  final String noDataTitle;
  final String noDataMessage;
  final String errorTitle;
  final String errorMessage;
  final String unauthorizedTitle;
  final String unauthorizedMessage;
  final String signIn;
  final String updateTitle;
  final String updateMessage;
  final String update;
  final String unsupportedTitle;
  final String unsupportedMessage;
}

/// Wraps [child] and shows a loader, an overlay loader or an error view
/// according to [viewState].
///
/// Works with `ViewState` from a Bloc state. It has no dependency on a router,
/// localisation or networking package; customise the output with [texts],
/// [errorBuilder] and [errorMessageResolver].
///
/// It fills the space it is given, so place it where the constraints are
/// bounded (for example as a `Scaffold` body).
///
/// For remote-controlled screens (TV) set [autofocusRetry] so the main action
/// of the default error view takes focus as soon as it appears.
class WithViewState extends StatefulWidget {
  const WithViewState({
    super.key,
    required this.viewState,
    required this.child,
    this.isRefreshable = false,
    this.retryAction = _noop,
    this.errorDisplayMode = ErrorDisplayMode.replace,
    this.errorBuilder,
    this.errorMessageResolver,
    this.texts = const ViewStateTexts(),
    this.autofocusRetry = false,
  });

  final ViewState viewState;
  final Widget child;

  /// Adds pull-to-refresh around [child] that calls [retryAction].
  final bool isRefreshable;

  /// Called by the Retry (or main action) button of the default error views.
  final VoidCallback retryAction;

  final ErrorDisplayMode errorDisplayMode;

  /// Replaces the default error view for any state. Return `null` to fall back.
  final ViewStateErrorBuilder? errorBuilder;

  /// Reads a message from `errorModel`. Without it, only a `String` model is
  /// shown.
  final ErrorMessageResolver? errorMessageResolver;

  final ViewStateTexts texts;

  /// Gives the main button of the default error view initial focus.
  final bool autofocusRetry;

  static void _noop() {}

  @override
  State<WithViewState> createState() => _WithViewStateState();
}

class _WithViewStateState extends State<WithViewState> {
  bool _isSheetOpen = false;
  Type? _lastShownErrorType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeShowSheet();
    });
  }

  @override
  void didUpdateWidget(WithViewState oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeShowSheet();
  }

  void _maybeShowSheet() {
    final state = widget.viewState;
    if (!state.isError) {
      _lastShownErrorType = null;
      return;
    }
    if (widget.errorDisplayMode == ErrorDisplayMode.bottomSheet &&
        !_isSheetOpen &&
        state.runtimeType != _lastShownErrorType) {
      _lastShownErrorType = state.runtimeType;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showSheet();
      });
    }
  }

  void _showSheet() {
    final view = _errorView(context);
    if (view == null || !widget.viewState.isError || _isSheetOpen) return;
    _isSheetOpen = true;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(child: Wrap(children: [view])),
    ).whenComplete(() {
      if (mounted) _isSheetOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewState;
    final replaceWithError =
        widget.errorDisplayMode == ErrorDisplayMode.replace && state.isError;

    Widget content = widget.child;
    if (widget.isRefreshable) {
      content = RefreshIndicator.adaptive(
        onRefresh: () async => widget.retryAction(),
        child: widget.child,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Visibility(
          visible: !replaceWithError,
          maintainState: true,
          child: content,
        ),
        if (state is Loading) _loader(),
        if (state is OverlayLoading) _loader(color: state.color),
        if (replaceWithError)
          Positioned.fill(
            child: _errorView(context) ?? const SizedBox.shrink(),
          ),
      ],
    );
  }

  Widget _loader({Color? color}) => Positioned.fill(
        child: ColoredBox(
          color: color ?? Colors.transparent,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );

  String? _message(dynamic model) {
    final custom = widget.errorMessageResolver?.call(model);
    if (custom != null && custom.isNotEmpty) return custom;
    return model is String && model.isNotEmpty ? model : null;
  }

  Widget? _errorView(BuildContext context) {
    final state = widget.viewState;
    final custom = widget.errorBuilder?.call(
      context,
      state,
      widget.retryAction,
    );
    if (custom != null) return custom;

    final t = widget.texts;
    switch (state) {
      case NoNetwork():
        return _panel(
          t.noNetworkTitle,
          t.noNetworkMessage,
          Icons.wifi_off,
          t.retry,
          widget.retryAction,
        );
      case NoData():
        return _panel(
          t.noDataTitle,
          t.noDataMessage,
          Icons.inbox_outlined,
          null,
          null,
        );
      case ServerError(errorModel: final m):
      case SearchError(errorModel: final m):
      case UnexpectedError(errorModel: final m):
        return _panel(
          t.errorTitle,
          _message(m) ?? t.errorMessage,
          Icons.error_outline,
          t.retry,
          widget.retryAction,
        );
      case Unauthorized(errorModel: final m):
        return _panel(
          t.unauthorizedTitle,
          _message(m) ?? t.unauthorizedMessage,
          Icons.lock_outline,
          t.signIn,
          widget.retryAction,
        );
      case ForceUpdateError(errorModel: final m):
        return _panel(
          t.updateTitle,
          _message(m) ?? t.updateMessage,
          Icons.system_update,
          t.update,
          widget.retryAction,
        );
      case JailBroken():
        return _panel(
          t.unsupportedTitle,
          t.unsupportedMessage,
          Icons.gpp_bad_outlined,
          null,
          null,
        );
      case CustomErrorState():
        return _panel(
          state.title ?? '',
          state.message ?? '',
          Icons.error_outline,
          (state.buttonText ?? '').isEmpty ? null : state.buttonText,
          state.onPressed,
          secondaryLabel: state.secondaryButtonText.isEmpty
              ? null
              : state.secondaryButtonText,
          onSecondary: state.onSecondaryPressed,
        );
      default:
        return null;
    }
  }

  Widget _panel(
    String title,
    String message,
    IconData icon,
    String? actionLabel,
    VoidCallback? onAction, {
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                FilledButton(
                  autofocus: widget.autofocusRetry,
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ],
              if (secondaryLabel != null && onSecondary != null) ...[
                const SizedBox(height: 8),
                TextButton(onPressed: onSecondary, child: Text(secondaryLabel)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
