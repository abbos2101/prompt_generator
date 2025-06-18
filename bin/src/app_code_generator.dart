import 'dart:io';

class AppCodeGenerator {
  final List<String> includePaths;
  final List<String> skipFiles;
  final bool needYaml;
  final String savedFile;
  final bool copyToClipboard;

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
  });

  factory AppCodeGenerator.fromJson(dynamic json) {
    return AppCodeGenerator(
      needYaml: json['needYaml'] ?? false,
      savedFile: json['savedFile'] ?? 'app-code.txt',
      copyToClipboard: json['copyToClipboard'] ?? false,
      includePaths:
          ((json['includePaths'] ?? []) as List).map((e) => '$e').toList(),
      skipFiles: ((json['skipFiles'] ?? []) as List).map((e) => '$e').toList(),
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
      sb.writeln(e.path);
      sb.writeln("```dart");
      sb.writeln(File(e.path).readAsStringSync());
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
