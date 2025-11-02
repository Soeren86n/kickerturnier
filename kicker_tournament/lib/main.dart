import 'package:flutter/material.dart';
import 'package:kicker_tournament/app.dart';
import 'package:kicker_tournament/core/di/locator.dart';

void main() {
  // Setup dependency injection
  setupLocator();
  runApp(const KickerApp());
}
