class DataFormatException implements Exception {
  DataFormatException(
    this.message, {
    this.originalData,
    this.stackTrace,
  });
  final String message;
  final dynamic originalData;
  final StackTrace? stackTrace;

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
  StorageException(this.message, {this.cause, this.stackTrace});
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

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
  ValidationException(this.message, {this.field});
  final String message;
  final String? field;

  @override
  String toString() {
    if (field != null) {
      return 'ValidationException [$field]: $message';
    }
    return 'ValidationException: $message';
  }
}
