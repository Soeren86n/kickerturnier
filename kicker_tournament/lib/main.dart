import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kicker_tournament/app.dart';
import 'package:kicker_tournament/core/di/locator.dart';
import 'package:kicker_tournament/core/logging/bloc_observer.dart';

void main() {
  // Setup dependency injection
  setupLocator();
  // Setup global BLoC observer for logging transitions and errors
  Bloc.observer = AppBlocObserver();
  runApp(const KickerApp());
}
