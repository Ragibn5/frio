import 'dart:convert';

import 'package:dart_extended_exceptions/dart_extended_exceptions.dart';
import 'package:flutter/foundation.dart';

import 'model_coder.dart';

/// A serializer/deserializer for encoding/decoding to/from json.
/// It also supports serialization/deserialization of primitive constructs.
abstract class JsonCoder extends ModelCoder {
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
      return data.toJson();
    } catch (e) {
      debugPrint(
        "Could not find a method called toJson(), "
        "trying with toMap()...",
      );
    }

    try {
      return data.toMap();
    } catch (e) {
      throw SerializationException(
        "Couldn't find a toJson()/toMap() method within the passed argument. "
        "Make sure you have a method called toJson()/toMap() within its class "
        "definition that returns its own encoded form.",
      );
    }
  }

  /// **Decodes [data] to the specified type.**
  /// - If it is is a primitive construct, returns as it is.
  /// - Else, tries to decode the the data to the specified type.
  ///
  /// In either case the return type should strictly be the specified type.
  /// If not, [SerializationException] exception is thrown.
  /// It also throws [SerializationException] in case there were any error
  /// decoding [data] to the expected type.
  @override
  ResultType decode<ResultType>(dynamic data) {
    if (_primitiveChecker.isPrimitiveConstruct(data)) {
      if (data.runtimeType != ResultType) {
        throw SerializationException(
          "The expected type was \"$ResultType\", "
          "but got response of type \"${data.runtimeType}\".",
        );
      }
      return data;
    } else if (data is Map<String, dynamic>) {
      final parser = getDecoder<ResultType>();
      if (parser == null) {
        throw SerializationException(
          "Could not find a registered decoder method "
          "(typically fromJson(...)/fromMap(...)) for type \"$ResultType\". "
          "Did you forget to register it with $addDecoder(...) ?",
        );
      }
      try {
        return parser(data);
      } catch (e) {
        throw SerializationException(
          "Failed to parse the argument to the target type \"$ResultType\". "
          "Make sure you have a proper mapping between \"$ResultType\" and "
          "the passed argument."
          "\nOriginal exception:\n$e"
          "\nPassed argument:\n${JsonEncoder.withIndent("  ").convert(data)}\n",
        );
      }
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
