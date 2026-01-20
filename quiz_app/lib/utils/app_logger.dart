import 'dart:developer' as developer;

/// ANSI color codes for terminal output
class _AnsiColor {
  static const String reset = '\x1B[0m';
  static const String green = '\x1B[32m';
  static const String blue = '\x1B[34m';
  static const String cyan = '\x1B[36m';
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
  static const String brightBlue = '\x1B[94m';
}

/// Centralized logging utility for the Queez app
///
/// Usage:
/// ```dart
/// AppLogger.info('User logged in');
/// AppLogger.debug('Variable value: $value');
/// AppLogger.warning('Deprecated API call');
/// AppLogger.error('Failed to load data', exception: e, stackTrace: st);
/// AppLogger.success('Operation completed');
/// ```
class AppLogger {
  static const String _tag = '[Queez]';
  static const bool _enableColors = true;

  /// Log an informational message (Blue)
  static void info(String message) {
    _log(message, logLevel: 'INFO', color: _AnsiColor.blue, icon: 'ℹ️');
  }

  /// Log a debug message (Cyan)
  static void debug(String message) {
    _log(message, logLevel: 'DEBUG', color: _AnsiColor.cyan, icon: '🔍');
  }

  /// Log a warning message (Yellow)
  static void warning(String message) {
    _log(message, logLevel: 'WARN', color: _AnsiColor.brightYellow, icon: '⚠️');
  }

  /// Log an error message (Red)
  /// Optionally include exception and stack trace for better debugging
  static void error(
    String message, {
    dynamic exception,
    StackTrace? stackTrace,
  }) {
    String fullMessage = message;
    if (exception != null) {
      fullMessage += '\nException: $exception';
    }
    if (stackTrace != null) {
      fullMessage += '\nStackTrace:\n$stackTrace';
    }
    _log(
      fullMessage,
      logLevel: 'ERROR',
      color: _AnsiColor.brightRed,
      icon: '❌',
    );
  }

  /// Log a success message (Green)
  static void success(String message) {
    _log(
      message,
      logLevel: 'SUCCESS',
      color: _AnsiColor.brightGreen,
      icon: '✅',
    );
  }

  /// Log a network/connection related message (Cyan)
  static void network(String message) {
    _log(message, logLevel: 'NETWORK', color: _AnsiColor.cyan, icon: '🌐');
  }

  /// Log a WebSocket related message (Bright Blue)
  static void websocket(String message) {
    _log(
      message,
      logLevel: 'WEBSOCKET',
      color: _AnsiColor.brightBlue,
      icon: '🔌',
    );
  }

  /// Log a database/storage related message (Green)
  static void database(String message) {
    _log(message, logLevel: 'DATABASE', color: _AnsiColor.green, icon: '💾');
  }

  /// Internal method to format and output logs
  static void _log(
    String message, {
    required String logLevel,
    required String color,
    required String icon,
  }) {
    final formattedMessage = '$icon $_tag[$logLevel] $message';

    // Color the entire log output including the message text
    final fullOutput = _enableColors
        ? '$color$formattedMessage${_AnsiColor.reset}'
        : formattedMessage;

    // Use developer.log for structured logging (visible in DevTools)
    // Note: We use debugPrint for console output to preserve ANSI colors
    // and avoid the "avoid_print" lint. This is the only acceptable place
    // for direct console output in the entire app.
    assert(() {
      // ignore: avoid_print
      print(fullOutput);
      return true;
    }());

    // Also log using developer.log for structured logging (visible in DevTools)
    developer.log(
      message,
      time: DateTime.now(),
      level: _getLogLevel(logLevel),
      name: logLevel,
    );
  }

  /// Convert log level string to numeric level for developer.log
  static int _getLogLevel(String levelName) {
    switch (levelName) {
      case 'DEBUG':
        return 0;
      case 'INFO':
        return 400;
      case 'WARN':
        return 900;
      case 'ERROR':
        return 1000;
      case 'SUCCESS':
        return 400;
      case 'NETWORK':
        return 500;
      case 'WEBSOCKET':
        return 500;
      case 'DATABASE':
        return 600;
      default:
        return 400;
    }
  }
}
