import 'dart:io';

import 'package:build/build.dart';
import 'package:frio/src/codegen/model_parser_config.dart';
import 'package:yaml/yaml.dart';

class ConfigReader {
  final BuilderOptions options;

  ConfigReader(this.options);

  Future<ModelParserConfig> readConfig() async {
    final configFile = options.config['config_file'];
    if (configFile == null) {
      throw StateError('Could not find frio_config.yaml');
    }

    final configYaml =
        loadYaml(await File(configFile).readAsString()) as YamlMap;

    final className =
        configYaml['frio_models_registerer']['class_name'] as String?;
    final outputFilePath =
        configYaml['frio_models_registerer']['output_file'] as String?;
    if (className == null || outputFilePath == null) {
      throw StateError('Invalid parser configuration');
    }

    return ModelParserConfig(
      outputPath: outputFilePath,
      outputClassName: className,
    );
  }
}
