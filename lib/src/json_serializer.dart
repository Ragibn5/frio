import 'package:dart_extended_exceptions/dart_extended_exceptions.dart';

import 'model_serializer.dart';

class JsonSerializer extends ModelSerializer {
  /// Encodes the request.
  @override
  dynamic encode(dynamic request) {
    if (!_isParseRequired(request)) {
      return request;
    } else {
      return _tryGetEncodedData(request);
    }
  }

  /// Decodes the response to the specified type.
  /// - If the response is a primitive, returns as it is.
  /// - Else, tries to decode the response to the specified type.
  ///
  /// In any case the return type should be the specified type.
  /// If not, [SerializationException] exception is thrown.
  @override
  ResultType decode<ResultType>(dynamic response) {
    if (_isPrimitive(response)) {
      if (response.runtimeType != ResultType) {
        throw SerializationException(
          "The expected type was ${ResultType.toString()}, "
          "but got response of type ${response.runtimeType}.",
        );
      }
      return response;
    } else if (response is Map<String, dynamic>) {
      final parser = getDecoder<ResultType>();
      if (parser == null) {
        throw SerializationException(
          "Could not find a registered json decoder method (typically fromJson(...)) "
          "for the type ${ResultType.toString()}.  Did you register it with "
          "${addDecoder.toString()} ?",
        );
      }
      return parser(response);
    } else {
      throw SerializationException(
        "The response is not parsable. "
        "Only primitive, Map<String, primitive | parsable> is supported.",
      );
    }
  }

  bool _isParseRequired(dynamic data) {
    return !(_isPrimitive(data) ||
        _isListOfPrimitive(data) ||
        _isMapOfPrimitive(data));
  }

  bool _isPrimitive(dynamic data) {
    return data is bool || data is num || data is String;
  }

  bool _isListOfPrimitive(dynamic data) {
    return data is List<bool> || data is List<num> || data is List<String>;
  }

  bool _isMapOfPrimitive(dynamic data) {
    return data is Map<String, bool> ||
        data is Map<String, num> ||
        data is Map<String, String>;
  }

  dynamic _tryGetEncodedData(dynamic data) {
    try {
      return data.toJson();
    } catch (_) {
      throw SerializationException(
        "Could not find a toJson() method within the request object. "
        "Make sure you have a toJson() method returning the JSON map as a member of the request object.",
      );
    }
  }
}
