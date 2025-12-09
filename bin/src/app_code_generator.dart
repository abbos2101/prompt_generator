import 'dart:io';

enum _SignatureType { none, function, method, getter, factory }

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

    // Skip imports for compressed files
    int startIndex = 0;
    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      if (trimmed.startsWith('import ') ||
          trimmed.startsWith('export ') ||
          trimmed.startsWith('part ') ||
          trimmed.isEmpty) {
        continue;
      }
      startIndex = i;
      break;
    }

    int braceCount = 0;
    bool inBody = false;
    String bodyIndent = '';

    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      // Count braces in current line
      int openBraces = _countChar(line, '{');
      int closeBraces = _countChar(line, '}');

      // If we're inside a body, skip until closed
      if (inBody) {
        braceCount += openBraces - closeBraces;
        if (braceCount <= 0) {
          inBody = false;
          result.writeln('$bodyIndent}');
        }
        continue;
      }

      // Check for function/method signature
      final signatureType = _getSignatureType(trimmed, i > 0 ? lines[i - 1].trim() : '');

      if (signatureType != _SignatureType.none) {
        // Arrow function (=>)
        if (line.contains('=>')) {
          final arrowIndex = line.indexOf('=>');
          result.writeln('${line.substring(0, arrowIndex + 2)} /* impl */;');
          // Skip continuation lines
          while (i + 1 < lines.length && !lines[i].trim().endsWith(';')) {
            i++;
          }
          continue;
        }

        // Body starts with {
        if (trimmed.endsWith('{')) {
          bodyIndent = _getIndent(line);
          result.writeln(line);
          result.writeln('$bodyIndent  /* impl */');
          braceCount = 1;
          inBody = true;
          continue;
        }

        // async/sync* - next line might have {
        if (trimmed.endsWith('async') || trimmed.endsWith('async*') || trimmed.endsWith('sync*')) {
          result.writeln(line);
          if (i + 1 < lines.length && lines[i + 1].trim() == '{') {
            i++;
            bodyIndent = _getIndent(lines[i]);
            result.writeln(lines[i]);
            result.writeln('$bodyIndent  /* impl */');
            braceCount = 1;
            inBody = true;
          }
          continue;
        }

        // Multi-line signature - look for { on next lines
        if (trimmed.endsWith(',') || trimmed.endsWith('(')) {
          result.writeln(line);
          // Continue writing signature lines until we find { or =>
          while (i + 1 < lines.length) {
            i++;
            final nextLine = lines[i];
            final nextTrimmed = nextLine.trim();

            if (nextLine.contains('=>')) {
              final arrowIndex = nextLine.indexOf('=>');
              result.writeln('${nextLine.substring(0, arrowIndex + 2)} /* impl */;');
              while (i + 1 < lines.length && !lines[i].trim().endsWith(';')) {
                i++;
              }
              break;
            }

            if (nextTrimmed.endsWith('{')) {
              bodyIndent = _getIndent(nextLine);
              result.writeln(nextLine);
              result.writeln('$bodyIndent  /* impl */');
              braceCount = 1;
              inBody = true;
              break;
            }

            if (nextTrimmed.endsWith('async') || nextTrimmed.endsWith('async*')) {
              result.writeln(nextLine);
              if (i + 1 < lines.length && lines[i + 1].trim() == '{') {
                i++;
                bodyIndent = _getIndent(lines[i]);
                result.writeln(lines[i]);
                result.writeln('$bodyIndent  /* impl */');
                braceCount = 1;
                inBody = true;
              }
              break;
            }

            result.writeln(nextLine);
          }
          continue;
        }
      }

      // Normal line - keep as is
      result.writeln(line);
    }

    return result.toString();
  }

  _SignatureType _getSignatureType(String trimmed, String prevLine) {
    // Skip comments
    if (trimmed.startsWith('//') ||
        trimmed.startsWith('/*') ||
        trimmed.startsWith('*')) {
      return _SignatureType.none;
    }

    // Skip class/mixin/enum/extension declarations
    if (trimmed.startsWith('class ') ||
        trimmed.startsWith('abstract class ') ||
        trimmed.startsWith('sealed class ') ||
        trimmed.startsWith('final class ') ||
        trimmed.startsWith('mixin ') ||
        trimmed.startsWith('enum ') ||
        trimmed.startsWith('extension ')) {
      return _SignatureType.none;
    }

    // Skip imports/exports/parts
    if (trimmed.startsWith('import ') ||
        trimmed.startsWith('export ') ||
        trimmed.startsWith('part ')) {
      return _SignatureType.none;
    }

    // Skip simple field declarations (no parentheses = not a function)
    if ((trimmed.startsWith('final ') ||
        trimmed.startsWith('late ') ||
        trimmed.startsWith('const ') ||
        trimmed.startsWith('static const ') ||
        trimmed.startsWith('static final ')) &&
        !trimmed.contains('(')) {
      return _SignatureType.none;
    }

    // Skip annotations (but @override is handled separately)
    if (trimmed.startsWith('@') && !trimmed.startsWith('@override')) {
      return _SignatureType.none;
    }

    // @override - next meaningful line is a method
    if (prevLine == '@override') {
      return _SignatureType.method;
    }

    // Factory constructor: factory ClassName...
    if (trimmed.startsWith('factory ')) {
      return _SignatureType.factory;
    }

    // Getter: Type get name => or Type get name {
    if (RegExp(r'\s+get\s+\w+').hasMatch(trimmed)) {
      return _SignatureType.getter;
    }

    // Top-level or class function with return type
    // Pattern: ReturnType<Generic>? functionName(... or Future<Type> name(
    final funcPattern = RegExp(
      r'^(static\s+)?(Future|Stream|void|dynamic|bool|int|double|num|String|List|Map|Set|Either|Option|Widget|Color|[A-Z]\w*)(<[^>]+>)?\??\s+\w+\s*\(',
    );
    if (funcPattern.hasMatch(trimmed)) {
      return _SignatureType.function;
    }

    // Method after @override (current line)
    if (trimmed.startsWith('@override')) {
      return _SignatureType.none; // Will be handled on next line
    }

    // Constructor: ClassName( or ClassName.named( - but NOT with return type before
    // Skip if it looks like: Type name( which is a function
    if (RegExp(r'^\w+\s*\(').hasMatch(trimmed) && !trimmed.contains(' ')) {
      // This is a constructor like ClassName() or _ClassName()
      return _SignatureType.none; // Don't compress constructors
    }
    if (RegExp(r'^\w+\.\w+\s*\(').hasMatch(trimmed) && !RegExp(r'^\w+\s+\w+\.\w+').hasMatch(trimmed)) {
      // Named constructor like ClassName.named()
      return _SignatureType.none;
    }

    return _SignatureType.none;
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