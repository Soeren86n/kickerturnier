class DataFormatException implements Exception {
  final String message;
  final dynamic originalData;
  final StackTrace? stackTrace;

  DataFormatException(
    this.message, {
    this.originalData,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('DataFormatException: $message');
    if (originalData != null) {
      buffer.write('\nOriginal data: $originalData');
    }
    return buffer.toString();
  }
}

/// Exception für Storage-/Persistence-Fehler
class StorageException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  StorageException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() {
    final buffer = StringBuffer('StorageException: $message');
    if (cause != null) {
      buffer.write(' (Cause: $cause)');
    }
    return buffer.toString();
  }
}

/// Exception für Validierungsfehler auf Domain-Ebene
class ValidationException implements Exception {
  final String message;
  final String? field;

  ValidationException(this.message, {this.field});

  @override
  String toString() {
    if (field != null) {
      return 'ValidationException [$field]: $message';
    }
    return 'ValidationException: $message';
  }
}
