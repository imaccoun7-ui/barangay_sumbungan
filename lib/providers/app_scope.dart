import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// Makes [AppState] available to every screen and rebuilds listeners when it
/// changes. Keeping it in an [InheritedNotifier] avoids prop-drilling and
/// works with a single, consistent state-management pattern.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in the widget tree.');
    return scope!.notifier!;
  }

  /// Reads the state without subscribing to rebuilds (for callbacks).
  static AppState read(BuildContext context) {
    final AppScope? scope =
        context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
