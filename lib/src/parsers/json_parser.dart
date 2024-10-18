import 'dart:convert';

import 'package:frio/src/codegen/frio_model_annotations.dart';
import 'package:frio/src/exceptions/parse_exception.dart';
import 'package:frio/src/parsers/model_parser.dart';

/// A serializer/deserializer for encoding/decoding to/from json.
/// It also supports serialization/deserialization of primitive constructs.
abstract class JsonParser extends ModelParser {
  final _primitiveChecker = _PrimitiveConstructChecker();

  /// **Encode [data].**
  /// <br>
  /// If it is a primitive construct, returns as it is.
  /// Else encodes before sending to underlying layer.
  /// <br>
  /// This method expects (if [data] is NOT a primitive construct) that
  /// [data] contains a method called [toJson] that returns its own json
  /// encoded form.
  @override
  dynamic encode(dynamic data) {
    if (_primitiveChecker.isPrimitiveConstruct(data)) {
      return data;
    }

    try {
      return data.toJson();
    } catch (e, st) {
      throw ParseException(
        "Couldn't find 'toJson()' method within the passed argument. "
        "Make sure you have called toJson() within the class definition"
        "that returns its own json map.",
        stackTrace: st,
      );
    }
  }

  /// **Decodes [data] to the specified type.**
  /// - If it is is a primitive construct, returns as it is.
  /// - Else, tries to decode the the data to the specified type.
  ///
  /// In either case the return type should strictly be the specified type.
  /// If not, [ParseException] exception is thrown.
  /// It also throws [ParseException] in case there were any error
  /// decoding [data] to the expected type.
  @override
  ResultType decode<ResultType>(dynamic data) {
    if (_primitiveChecker.isPrimitiveConstruct(data)) {
      if (data.runtimeType != ResultType) {
        throw ParseException(
          "The expected type was `$ResultType`, "
          "but got response of type \"${data.runtimeType}\".",
        );
      }
      return data;
    } else if (data is Map<String, dynamic>) {
      final parser = getDecoder<ResultType>();
      if (parser == null) {
        throw ParseException(
          "Could not find the decoder (fromJson(...)) for `$ResultType`."
          "\nDid you forget to register it with `addDecoder(...)`?"
          "\nConsider annotating the model with `$FrioJson` to auto register."
          "\n(Please run build runner afterwards to generate the json parser).",
        );
      }
      try {
        return parser(data);
      } catch (e, st) {
        throw ParseException(
          "Failed to parse the argument to the target type: `$ResultType`."
          "\nMake sure you have a proper mapping between `$ResultType` and "
          "the passed argument."
          "\nPassed argument:"
          "\n${const JsonEncoder.withIndent("  ").convert(data)}",
          stackTrace: st,
        );
      }
    } else {
      throw ParseException(
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
