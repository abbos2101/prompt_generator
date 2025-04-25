# PromptGenerator
<?code-excerpt path-base="example/lib"?>

[![pub package](https://img.shields.io/pub/v/prompt_generator.svg)](https://pub.dev/packages/prompt_generator)

A Flutter package that helps you generate prompts by collecting code from your project based on configuration.

## Features

- Generates a text file containing code from specified directories
- Configurable with YAML to set paths and file patterns
- Easily skip specific file types or directories
- Customize output file name

## Getting Started

Add `prompt_generator` to your `pubspec.yaml`:

```yaml
dev_dependencies:
  prompt_generator: ^latest_version
```

## Usage

### 1. Create configuration file

Create a `prompt_generator.yaml` file in your project root directory:

```yaml
needYaml: true
savedFile: "app-code.txt"
skipFiles: [
  '.freezed.dart',
  '.g.dart',
  '.res.dart',
  '.config.dart',
  'app-prompt.dart',
  '/.',
]
#filePatterns: ['%_page.dart'] # Optional: uncomment if you need to filter by patterns
includePaths: [
  'lib/presentation',
]
```

### 2. Run the generator

Execute the following command in your project directory:

```
dart run prompt_generator:generate
```

This will create the output file (default: `app-code.txt`) with the code from the specified directories.

## Configuration Options

| Option | Type | Description |
|--------|------|-------------|
| `needYaml` | boolean | Whether to include YAML configuration in the output |
| `savedFile` | string | Name of the output file |
| `skipFiles` | list | File patterns to ignore |
| `filePatterns` | list | Optional: Specific file patterns to include |
| `includePaths` | list | Directories to scan for code |

### Example Configuration

```yaml
# Basic configuration
needYaml: true
savedFile: "app-code.txt"
skipFiles: [
  '.freezed.dart',
  '.g.dart',
]
includePaths: [
  'lib/presentation',
  'lib/domain',
]

# With file patterns
needYaml: true
savedFile: "features-code.txt"
skipFiles: [
  '.freezed.dart',
  '.g.dart',
]
filePatterns: [
  '%_page.dart',
  '%_widget.dart',
]
includePaths: [
  'lib/features',
]
```

## Use Cases

This package is particularly useful for:

- Generating code documentation
- Creating prompts for AI coding assistants
- Sharing code snippets with others
- Analyzing your codebase structure

## Limitations

- The generator does not currently support symlinks
- Very large projects may take longer to process

## License

[Add your license information here]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.