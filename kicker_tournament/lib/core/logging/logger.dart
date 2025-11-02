import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Global logger instance used across the app.
///
/// Why: Centralizes logging configuration. In debug we want rich, pretty logs;
/// in release we keep logs concise and elevate level to info.
final Logger log = Logger(
  printer: kReleaseMode
      ? SimplePrinter()
      : PrettyPrinter(
          methodCount: 1,
          errorMethodCount: 5,
          lineLength: 80,
          colors: false,
          printEmojis: false,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
  level: kReleaseMode ? Level.info : Level.debug,
);
