import 'dart:io';

import "package:yaml/yaml.dart";

import 'src/app_code_generator.dart';

void main() {
  final string = File('prompt_generator.yaml').readAsStringSync();
  try {
    final json = loadYaml(string);
    AppCodeGenerator.fromJson(json).generateAppCodeFile();
    print('-= Finished =-');
  } catch (e) {
    print('-=- Error: $e -=-');
  }
}
