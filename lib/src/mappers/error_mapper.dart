abstract class ErrorMapper<T> {
  T mapError(Object exception, StackTrace? stackTrace);
}
