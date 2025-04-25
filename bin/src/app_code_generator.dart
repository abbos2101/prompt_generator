import 'dart:io';

class AppCodeGenerator {
  final List<String> includePaths;
  final List<String> skipFiles;
  final List<String> filePatterns;
  final bool needYaml;
  final String savedFile;

  const AppCodeGenerator({
    required this.includePaths,
    this.skipFiles = const [
      '.freezed.dart',
      '.g.dart',
      '.res.dart',
      '.config.dart',
      'app-prompt.dart',
      '/.',
    ],
    this.filePatterns = const [],
    this.needYaml = true,
    this.savedFile = 'app-prompt.txt',
  });

  factory AppCodeGenerator.fromJson(dynamic json) {
    return AppCodeGenerator(
      needYaml: json['needYaml'] ?? false,
      savedFile: json['savedFile'] ?? 'app-code.txt',
      includePaths:
          ((json['includePaths'] ?? []) as List).map((e) => '$e').toList(),
      skipFiles: ((json['skipFiles'] ?? []) as List).map((e) => '$e').toList(),
      filePatterns:
          ((json['filePatterns'] ?? []) as List).map((e) => '$e').toList(),
    );
  }

  /// Checks if file matches any of the patterns with SQL-like syntax
  /// "%" - any sequence of characters
  /// Examples: "%_page.dart", "home%", "%widget%.dart"
  bool _matchesPattern(String filePath) {
    if (filePatterns.isEmpty) return true;

    final fileName = filePath.split('/').last;
    for (final pattern in filePatterns) {
      if (!pattern.contains('%')) {
        if (fileName == pattern) return true;
        continue;
      }

      final regexPattern = '^${pattern.replaceAll('%', '.*')}\$';
      final regExp = RegExp(regexPattern);

      if (regExp.hasMatch(fileName)) return true;
    }

    return false;
  }

  void generateAppCodeFile() {
    final prompt = File(savedFile);
    final yaml = File('pubspec.yaml');
    final files = Directory('lib').listSync(recursive: true).where((e) {
      if (e is File) {
        // Skip generated files
        if (skipFiles.any(
          (pattern) =>
              e.path.endsWith(pattern) ||
              (pattern == '/.' && e.path.lastIndexOf(pattern) != -1),
        )) {
          return false;
        }

        // Check if file is in includePaths
        final isInIncludePath = includePaths.any(
          (path) => e.path.contains(path),
        );
        if (!isInIncludePath) {
          return false;
        }

        // Check if file matches any pattern
        if (!_matchesPattern(e.path)) {
          return false;
        }

        return true;
      }
      return false;
    });

    final sb = StringBuffer();

    // Write pubspec.yaml if needed
    if (needYaml) {
      sb.writeln('pubspec.yaml');
      sb.writeln("```yaml");
      sb.writeln(yaml.readAsStringSync());
      sb.writeln("```");
      sb.writeln();
    }

    // Write filtered dart files
    for (var e in files) {
      sb.writeln(e.path);
      sb.writeln("```dart");
      sb.writeln(File(e.path).readAsStringSync());
      sb.writeln("```");
      sb.writeln();
    }

    prompt.writeAsStringSync(sb.toString());
  }
}
