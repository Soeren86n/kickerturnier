import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kicker_tournament/core/logging/logger.dart';

/// Logs BLoC transitions and unhandled errors.
///
/// Why: Helps diagnose state changes and failures in production and tests
/// without sprinkling print statements in feature code.
class AppBlocObserver extends BlocObserver {
  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    log.t(
      'Transition: ${bloc.runtimeType} ${transition.currentState} -> ${transition.nextState} via ${transition.event}',
    );
  }

  @override
  void onError(
    BlocBase<dynamic> bloc,
    Object error,
    StackTrace stackTrace,
  ) {
    log.e('Bloc error in ${bloc.runtimeType}', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
