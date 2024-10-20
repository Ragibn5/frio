import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:frio/src/codegen/frio_model_annotations.dart';
import 'package:frio/src/codegen/generator_storage.dart';
import 'package:source_gen/source_gen.dart';

Builder jsonModelDataCollector(BuilderOptions options) {
  // Clear corresponding storage before starting.
  // This ensures we do not get components from a previous run.
  GeneratorStorage.jsonModelUris.clear();
  GeneratorStorage.jsonModelClassNames.clear();

  return SharedPartBuilder(
    [JsonModelDataCollector()],
    'parser',
  );
}

class JsonModelDataCollector extends GeneratorForAnnotation<FrioJson> {
  @override
  void generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    // check if the annotated entity is a class, if not, return.
    if (element is! ClassElement) {
      return;
    }

    // Retrieve `requireToJson` and `requireFromJson` from the annotation
    final requireToJson = annotation.read('requireToJson').boolValue;
    final requireFromJson = annotation.read('requireFromJson').boolValue;

    // Check for a factory constructor named `fromJson`
    final fromJsonFactory = element.constructors
        .where(
          (constructor) =>
              constructor.isFactory &&
              constructor.name == 'fromJson' &&
              constructor.returnType == element.thisType,
        )
        .firstOrNull;

    // If no factory, check for a static method named `fromJson`
    final fromJsonStaticMethod = element.methods
        .where(
          (method) =>
              method.isStatic &&
              method.name == 'fromJson' &&
              method.returnType == element.thisType &&
              method.parameters.isNotEmpty &&
              method.parameters.first.type
                      .getDisplayString(withNullability: false) ==
                  'Map<String, dynamic>',
        )
        .firstOrNull;

    // Check if the class has a `toJson` method
    final toJsonMethod = element.methods
        .where(
          (method) =>
              method.name == 'toJson' &&
              method.returnType.getDisplayString(withNullability: false) ==
                  'Map<String, dynamic>',
        )
        .firstOrNull;

    // If requireFromJson == true, and,
    // If neither a factory constructor nor a static method is found,
    // throw an error.
    if (fromJsonFactory == null && fromJsonStaticMethod == null) {
      if (requireFromJson) {
        throw StateError(
          "Class `${element.name}` does not have a valid "
          '`fromJson` factory constructor or static method.',
        );
      }
    }

    // Get the value of `require_toJson` from the annotation,
    if (toJsonMethod == null) {
      if (requireToJson) {
        throw StateError(
          'Class `${element.name}` does not have a valid `toJson` method.',
        );
      }
    }

    // finally add to temporary storage
    GeneratorStorage.jsonModelClassNames.add(element.name);
    GeneratorStorage.jsonModelUris.add(element.library.source.uri.toString());
  }
}
