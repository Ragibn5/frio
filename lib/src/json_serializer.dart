import 'package:dart_extended_exceptions/dart_extended_exceptions.dart';
import 'package:flutter/foundation.dart';

import 'model_serializer.dart';

class JsonSerializer extends ModelSerializer {
  final _primitiveChecker = _PrimitiveConstructChecker();

  /// **Encode [data].**
  /// <br>
  /// If it is a primitive construct, returns as it is.
  /// Else encodes before sending to underlying layer.
  /// <br>
  /// This method expects (if [data] is NOT a primitive construct) that
  /// [data] contains a method called [toMap] or [toJson] that returns its
  /// encoded form.
  @override
  dynamic encode(dynamic data) {
    if (_primitiveChecker.isPrimitiveConstruct(data)) {
      return data;
    }

    try {
      return data.toMap();
    } catch (e) {
      debugPrint(
        "Could not find a method called toMap(), trying with toJson()...",
      );
    }

    try {
      return data.toJson();
    } catch (e) {
      throw SerializationException(
        "Could not find a toMap() or toJson() method within the object. "
        "Make sure you have a method called toMap() or toJson() method its "
        "class definition that returns its own encoded form.",
      );
    }
  }

  /// **Decodes [data] to the specified type.**
  /// - If it is is a primitive construct, returns as it is.
  /// - Else, tries to decode the the data to the specified type.
  ///
  /// In either case the return type should strictly be the specified type.
  /// If not, [SerializationException] exception is thrown.
  @override
  ResultType decode<ResultType>(dynamic data) {
    if (_primitiveChecker.isPrimitiveConstruct(data)) {
      if (data.runtimeType != ResultType) {
        throw SerializationException(
          "The expected type was $ResultType, "
          "but got response of type ${data.runtimeType}.",
        );
      }
      return data;
    } else if (data is Map<String, dynamic>) {
      final parser = getDecoder<ResultType>();
      if (parser == null) {
        throw SerializationException(
          "Could not find a registered decoder method "
          "(typically fromJson(...) or fromMap(...)) for the type $ResultType."
          "Did you forget to register it with $addDecoder(...) ?",
        );
      }
      return parser(data);
    } else {
      throw SerializationException(
        "The response is not parsable. Only the following are supported:\n"
        "- Primitive\n"
        "- List<Primitive>\n"
        "- Map<Primitive, Primitive>\n"
        "- Map<String, Parsable> (Json map)\n",
      );
    }
  }
}

class _PrimitiveConstructChecker {
  bool isPrimitiveConstruct(dynamic data) {
    return isPrimitive(data) ||
        isListOfPrimitive(data) ||
        isMapOfPrimitive(data);
  }

  bool isPrimitive(dynamic data) {
    return data is bool || data is num || data is String;
  }

  bool isListOfPrimitive(dynamic data) {
    return data is List<bool> || data is List<num> || data is List<String>;
  }

  bool isMapOfPrimitive(dynamic data) {
    return data is Map<bool, bool> ||
        data is Map<bool, num> ||
        data is Map<bool, String> ||
        data is Map<num, bool> ||
        data is Map<num, num> ||
        data is Map<num, String> ||
        data is Map<String, bool> ||
        data is Map<String, num> ||
        data is Map<String, String>;
  }
}
