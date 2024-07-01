typedef Decoder<T> = T Function(Map<String, dynamic> jsonMap);

abstract class ModelSerializer {
  final Map<Type, Decoder> _parserMap = {};

  /// **Get the decoder for the requested type.**
  /// <br>
  /// You must specify the type parameter,
  /// otherwise it may return null, or generic type.
  ///
  /// If a decoded was added earlier (with [addDecoder] method call),
  /// it is guaranteed to return the decoder for that type, otherwise
  /// it returns null.
  Decoder<ResultType>? getDecoder<ResultType>() {
    final parser = _parserMap[ResultType];
    if (parser != null) {
      return parser as Decoder<ResultType>;
    } else {
      return null;
    }
  }

  /// **Adds a the supplied decoder to the supported decoder list.**
  /// <br>
  /// Later, the decoder will internally use this to decode
  /// the encoded data to the expected type. If the decoder
  /// was not added, you should throw an exception or take a similar action.
  void addDecoder<ResultType>(Decoder<ResultType> decoder) {
    _parserMap[ResultType] = decoder;
  }

  /// **Encode [data].**
  /// <br>
  /// If it is a primitive construct, should return as it is.
  /// Else encode if necessary before sending to underlying layer.
  dynamic encode(dynamic data);

  /// **Try to decode [data] to the specified type.**
  /// - If it is a primitive construct, return as it is.
  /// - Else, try to decode the data to the specified type.
  ///
  /// In either case the return type should strictly be the specified type.
  /// If not, an exception should be thrown, or similar action must be taken.
  ResultType decode<ResultType>(dynamic data);
}
