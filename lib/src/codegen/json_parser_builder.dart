import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:frio/src/codegen/config_reader.dart';
import 'package:frio/src/codegen/generator_storage.dart';
import 'package:frio/src/codegen/model_parser_config.dart';
import 'package:frio/src/parsers/json_parser.dart';

PostProcessBuilder jsonParserBuilder(BuilderOptions options) =>
    JsonParserBuilder(ConfigReader(options));

class JsonParserBuilder extends PostProcessBuilder {
  final ConfigReader configReader;

  JsonParserBuilder(this.configReader);

  @override
  FutureOr<void> build(PostProcessBuildStep buildStep) async {
    final config = await configReader.readConfig();

    // preprocess decoder data
    GeneratorStorage.jsonModelUris.sort((a, b) => a.compareTo(b));
    GeneratorStorage.jsonModelClassNames.sort((a, b) => a.compareTo(b));

    // build the parser file content and write to file
    await _writeToTarget(
      config,
      _buildSourceContent(
        config,
        GeneratorStorage.jsonModelUris,
        GeneratorStorage.jsonModelClassNames,
      ),
    );
  }

  /// ###### Dummy
  /// We do not use it in any way.
  @override
  Iterable<String> get inputExtensions => [".dart"];

  String _buildSourceContent(
    ModelParserConfig config,
    List<String> decoderUris,
    List<String> decoderNames,
  ) {
    // build an imports statements map - (using map to avoid duplicates)
    final importsMap = <String, String>{};
    for (final uri in decoderUris) {
      final statement = "import '$uri';";
      importsMap[statement] = statement;
    }

    // build an registration statement list
    final registrationsMap = <String, String>{};
    for (final name in decoderNames) {
      final statement = "addDecoder($name.fromJson);";
      registrationsMap[statement] = statement;
    }

    return '''
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:frio/frio.dart';
${importsMap.values.join('\n')}

class ${config.outputClassName} extends $JsonParser {
  ${config.outputClassName}() {
    ${registrationsMap.values.join('\n')}
  }
}
''';
  }

  Future<void> _writeToTarget(
    ModelParserConfig parserConfig,
    String sourceContent,
  ) async {
    final file = File(parserConfig.outputPath);
    if (!(await file.exists())) {
      await file.create(recursive: true);
    }

    await file.writeAsString(sourceContent, flush: true);
  }
}
