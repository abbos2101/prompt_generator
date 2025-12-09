import 'dart:io';

class AppCodeGenerator {
  final List<String> includePaths;
  final List<String> skipFiles;
  final bool needYaml;
  final String savedFile;
  final bool copyToClipboard;
  final bool compressService;
  final List<String> doNotCompressPaths;

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
    this.needYaml = true,
    this.savedFile = 'app-prompt.txt',
    this.copyToClipboard = false,
    this.compressService = false,
    this.doNotCompressPaths = const [
      '_model.dart',
      '_facade.dart',
      '_state.dart',
      '_event.dart',
    ],
  });

  factory AppCodeGenerator.fromJson(dynamic json) {
    return AppCodeGenerator(
      needYaml: json['needYaml'] ?? false,
      copyToClipboard: json['copyToClipboard'] ?? false,
      compressService: json['compressService'] ?? false,
      savedFile: json['savedFile'] ?? 'app-code.txt',
      includePaths:
      ((json['includePaths'] ?? []) as List).map((e) => '$e').toList(),
      skipFiles: ((json['skipFiles'] ?? []) as List).map((e) => '$e').toList(),
      doNotCompressPaths:
      ((json['doNotCompressPaths'] ?? []) as List).map((e) => '$e').toList(),
    );
  }

  /// Normalizes include paths - adds "/" at the end if it's a folder
  List<String> _normalizeIncludePaths() {
    return includePaths.map((path) {
      // If path contains "." (indicates file), do nothing
      if (path.contains('.')) {
        return path;
      }

      // If it's a folder and doesn't end with "/", add it
      if (!path.endsWith('/')) {
        return '$path/';
      }

      return path;
    }).toList();
  }

  /// Copies text to clipboard using platform-specific commands
  Future<void> _copyToClipboard(String text) async {
    try {
      if (Platform.isWindows) {
        // Windows - use clip command
        final process = await Process.start('clip', []);
        process.stdin.write(text);
        await process.stdin.close();
        await process.exitCode;
      } else if (Platform.isMacOS) {
        // macOS - use pbcopy command
        final process = await Process.start('pbcopy', []);
        process.stdin.write(text);
        await process.stdin.close();
        await process.exitCode;
      } else if (Platform.isLinux) {
        // Linux - try xclip first, then xsel as fallback
        try {
          final process =
          await Process.start('xclip', ['-selection', 'clipboard']);
          process.stdin.write(text);
          await process.stdin.close();
          await process.exitCode;
        } catch (e) {
          // Fallback to xsel if xclip is not available
          final process =
          await Process.start('xsel', ['--clipboard', '--input']);
          process.stdin.write(text);
          await process.stdin.close();
          await process.exitCode;
        }
      }
      print('✓ Content copied to clipboard');
    } catch (e) {
      print('⚠ Failed to copy to clipboard: $e');
      print('  Make sure clipboard tools are installed:');
      if (Platform.isLinux) {
        print('  - Linux: sudo apt install xclip (or xsel)');
      }
    }
  }

  /// Check if file should keep full code (skip compression)
  bool _shouldKeepFull(String filePath) {
    return doNotCompressPaths.any((pattern) => filePath.contains(pattern));
  }

  /// Compress dart code - replace method bodies with /* impl */
  String _compressCode(String content, String filePath) {
    if (!compressService || _shouldKeepFull(filePath)) {
      return content;
    }

    final result = StringBuffer();
    final lines = content.split('\n');

    int braceCount = 0;
    bool inMethodBody = false;
    String methodIndent = '';
    bool isArrowFunction = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      // Count braces in current line
      int openBraces = _countChar(line, '{');
      int closeBraces = _countChar(line, '}');

      // If we're inside a method body, skip until closed
      if (inMethodBody) {
        braceCount += openBraces - closeBraces;
        if (braceCount <= 0) {
          inMethodBody = false;
          result.writeln('$methodIndent}');
        }
        continue;
      }

      // Detect method start
      if (_isMethodSignature(trimmed)) {
        // Arrow function (=>)
        if (line.contains('=>')) {
          // Short arrow - keep as is
          if (line.length <= 80 && (trimmed.endsWith(';') || trimmed.endsWith(','))) {
            result.writeln(line);
            continue;
          }
          // Long arrow - compress
          final arrowIndex = line.indexOf('=>');
          result.writeln('${line.substring(0, arrowIndex + 2)} /* impl */;');
          // Skip continuation lines if any
          while (i + 1 < lines.length && !lines[i].trimLeft().endsWith(';')) {
            i++;
          }
          continue;
        }

        // Method with body {
        if (trimmed.endsWith('{')) {
          methodIndent = _getIndent(line);
          result.writeln(line);
          result.writeln('$methodIndent  /* impl */');
          braceCount = 1;
          inMethodBody = true;
          continue;
        }

        // Async method - next line might have {
        if (trimmed.endsWith('async') || trimmed.endsWith('async*') || trimmed.endsWith('sync*')) {
          result.writeln(line);
          // Check next line for {
          if (i + 1 < lines.length && lines[i + 1].trim() == '{') {
            i++;
            methodIndent = _getIndent(lines[i]);
            result.writeln(lines[i]);
            result.writeln('$methodIndent  /* impl */');
            braceCount = 1;
            inMethodBody = true;
          }
          continue;
        }
      }

      // Normal line - keep as is
      result.writeln(line);
    }

    return result.toString();
  }

  /// Check if line is a method signature
  bool _isMethodSignature(String trimmed) {
    // Skip comments, imports, fields
    if (trimmed.startsWith('//') ||
        trimmed.startsWith('/*') ||
        trimmed.startsWith('*') ||
        trimmed.startsWith('import ') ||
        trimmed.startsWith('export ') ||
        trimmed.startsWith('part ')) {
      return false;
    }

    // Skip class/mixin declarations
    if (trimmed.startsWith('class ') ||
        trimmed.startsWith('abstract class ') ||
        trimmed.startsWith('mixin ') ||
        trimmed.startsWith('enum ') ||
        trimmed.startsWith('extension ')) {
      return false;
    }

    // Skip constructors (ClassName() or ClassName.named())
    if (RegExp(r'^\w+\s*\(').hasMatch(trimmed) && !trimmed.contains(' ')) {
      return false;
    }
    if (RegExp(r'^\w+\.\w+\s*\(').hasMatch(trimmed)) {
      return false;
    }

    // Skip field declarations without ()
    if ((trimmed.startsWith('final ') ||
        trimmed.startsWith('late ') ||
        trimmed.startsWith('static ') ||
        trimmed.startsWith('const ')) &&
        !trimmed.contains('(')) {
      return false;
    }

    // Skip simple getters (one line)
    if (trimmed.contains(' get ') && trimmed.contains('=>') && trimmed.endsWith(';')) {
      return false;
    }

    // Method patterns
    final hasReturnType = RegExp(
      r'^(Future|void|String|int|double|bool|List|Map|Set|dynamic|Stream|Either|Option|Widget|State|\w+Model|\w+State)',
    ).hasMatch(trimmed);

    final hasMethodParens = trimmed.contains('(') &&
        (trimmed.contains(') {') ||
            trimmed.contains(') async') ||
            trimmed.contains(') =>') ||
            trimmed.contains(') sync'));

    final isOverride = trimmed.startsWith('@override');

    return hasReturnType && hasMethodParens || isOverride;
  }

  /// Get indentation of a line
  String _getIndent(String line) {
    final match = RegExp(r'^(\s*)').firstMatch(line);
    return match?.group(1) ?? '';
  }

  /// Count occurrences of a character in string
  int _countChar(String str, String char) {
    int count = 0;
    bool inString = false;
    String? stringChar;

    for (int i = 0; i < str.length; i++) {
      final c = str[i];

      // Track string literals
      if ((c == '"' || c == "'") && (i == 0 || str[i - 1] != '\\')) {
        if (!inString) {
          inString = true;
          stringChar = c;
        } else if (c == stringChar) {
          inString = false;
        }
      }

      // Only count if not in string
      if (!inString && c == char) {
        count++;
      }
    }

    return count;
  }

  Future<void> generateAppCodeFile() async {
    final prompt = File(savedFile);
    final yaml = File('pubspec.yaml');
    final normalizedPaths = _normalizeIncludePaths();

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

        // Check if file is in include paths
        final isInIncludePath = normalizedPaths.any(
              (path) => e.path.startsWith(path),
        );
        if (!isInIncludePath) {
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
      final filePath = e.path;
      final fileContent = File(filePath).readAsStringSync();
      final processedContent = _compressCode(fileContent, filePath);

      sb.writeln(filePath);
      sb.writeln("```dart");
      sb.writeln(processedContent);
      sb.writeln("```");
      sb.writeln();
    }

    final content = sb.toString();

    // Save to file only if savedFile is not empty
    if (savedFile.isNotEmpty) {
      prompt.writeAsStringSync(content);
    }

    // Copy to clipboard if requested
    if (copyToClipboard) {
      await _copyToClipboard(content);
    }
  }
}