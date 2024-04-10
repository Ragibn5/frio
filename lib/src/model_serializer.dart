typedef JsonParser<T> = T Function(Map<String, dynamic> jsonMap);

abstract class ModelSerializer {
  final Map<Type, JsonParser> _jsonParserMap = {};

  JsonParser<ResultType>? getDecoder<ResultType>() {
    final parser = _jsonParserMap[ResultType];
    if (parser != null) {
      return parser as JsonParser<ResultType>;
    } else {
      return null;
    }
  }

  void addDecoder<ResultType>(JsonParser<ResultType> decoder) {
    _jsonParserMap[ResultType] = decoder;
  }

  /// Encode the request.
  /// If it is a primitive, keep as it is.
  /// Else encode if necessary before sending to underlying layer.
  dynamic encode(dynamic request);

  /// Should try to decode the response to the specified type.
  /// - If the response is a primitive, return as it is.
  /// - Else, try to decode the response to the specified type.
  ///
  /// In any case the return type should be the specified type.
  /// If not, an exception should be thrown.
  ResultType decode<ResultType>(dynamic response);
}
