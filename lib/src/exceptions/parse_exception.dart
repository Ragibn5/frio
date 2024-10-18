class ParseException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  ParseException(
    this.message, {
    this.stackTrace,
  });

  @override
  String toString() {
    return '\n*** $runtimeType ***\n$message';
  }
}
