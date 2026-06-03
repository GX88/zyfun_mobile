enum AppErrorType {
  network,
  database,
  parse,
  player,
  permission,
  storage,
  unknown,
}

class AppException implements Exception {
  const AppException({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  final AppErrorType type;
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException(type: $type, message: $message)';
}
