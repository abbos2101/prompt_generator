# PromptGenerator

[![pub package](https://img.shields.io/pub/v/prompt_generator.svg)](https://pub.dev/packages/prompt_generator)

🌐 **[English](https://github.com/abbos2101/prompt_generator/blob/main/README.md)** | **[O'zbekcha](https://github.com/abbos2101/prompt_generator/blob/main/README_UZ.md)**

**Stop asking teammates for context. Stop feeling overwhelmed by unfamiliar codebases. Let AI understand your entire Flutter project instantly.**

A Flutter package that bridges the gap between your codebase and AI assistants by intelligently collecting and formatting your project's code for Claude, ChatGPT, DeepSeek, Grok, and other AI tools.

## Why PromptGenerator?

Ever joined a new project and felt lost? Ever received a task from a senior developer but hesitated to ask "basic" questions? Ever wished you could discuss your architecture decisions with an expert without bothering your team?

**PromptGenerator solves this.** It extracts your project's relevant code into a single, AI-ready format that you can paste directly into any AI assistant. No more manual file hunting, no more incomplete context, no more embarrassment.

## What It Does

- **Instant AI Context**: Generate a comprehensive snapshot of your codebase in seconds
- **Smart Selection**: Configure exactly which files and directories matter
- **AI-Optimized**: Outputs in a format that AI assistants understand perfectly
- **Privacy-First**: Automatically skip generated files (.g.dart, .freezed.dart) and sensitive data
- **Zero Setup**: Simple YAML configuration, one command to run
- **Code Compression**: Reduce token usage by 40-60% while preserving code structure

## Perfect For

- 🆕 **Onboarding to unfamiliar projects** - Understand architecture without pestering teammates
- 🤖 **AI-Assisted Development** - Get expert-level guidance on your specific codebase
- 📚 **Code Reviews** - Share context-rich code snippets with AI for analysis
- 🏗️ **Architecture Discussions** - Discuss refactoring strategies with full project context
- 📖 **Documentation** - Generate comprehensive codebase overviews
- 👥 **Team Collaboration** - Share project structure with new developers
- 🔍 **Code Analysis** - Let AI identify patterns, issues, or improvement opportunities

## Getting Started

Add `prompt_generator` to your `pubspec.yaml`:
```yaml
dev_dependencies:
  prompt_generator: ^latest_version
```

## Usage

### 1. Create Configuration File

Create a `prompt_generator.yaml` file in your project root:
```yaml
needYaml: true
copyToClipboard: false
savedFile: "app-code.txt" # Leave empty to skip saving
skipFiles: [
  '.freezed.dart',
  '.g.dart',
  '.res.dart',
  '.config.dart',
  '/.',
]
includePaths: [
  lib/presentation,
  lib/domain,
]
```

### 2. Generate Your Prompt

Run this command in your project directory:
```bash
dart run prompt_generator:generate
```

### 3. Share with AI

Copy the generated `app-code.txt` content and paste it directly into Claude, ChatGPT, DeepSeek, Grok, or any AI assistant. Now you can:

- Ask architectural questions about YOUR specific project
- Request refactoring suggestions based on YOUR actual code
- Get implementation help that understands YOUR context
- Debug issues with full project awareness

## Configuration Options

| Option               | Type    | Description                                              |
|----------------------|---------|----------------------------------------------------------|
| `needYaml`           | boolean | Include YAML configuration files in output               |
| `copyToClipboard`    | boolean | Automatically copy output to clipboard                   |
| `savedFile`          | string  | Output filename (leave empty to skip file creation)      |
| `skipFiles`          | list    | File patterns to exclude (supports wildcards)            |
| `includePaths`       | list    | Directories to include in the output                     |
| `compressService`    | boolean | Enable code compression to reduce tokens (default: false)|
| `doNotCompressPaths` | list    | File patterns to exclude from compression                |

### Configuration Examples

**Minimal Setup** - Just the essentials:
```yaml
needYaml: false
copyToClipboard: true
savedFile: "my-project.txt"
skipFiles: ['.g.dart', '.freezed.dart']
includePaths: [lib/]
```

**Feature-Focused** - Specific features only:
```yaml
needYaml: true
copyToClipboard: false
savedFile: "feature-code.txt"
skipFiles: ['.freezed.dart', '.g.dart', '_test.dart']
includePaths: [
  lib/features/auth,
  lib/features/profile,
]
```

**Full Project** - Comprehensive overview:
```yaml
needYaml: true
copyToClipboard: true
savedFile: "full-project.txt"
skipFiles: [
  '.freezed.dart',
  '.g.dart',
  '.res.dart',
  '/.',
]
includePaths: [
  lib/presentation,
  lib/domain,
  lib/data,
  lib/core,
]
```

**With Compression** - Reduce token usage for large projects:
```yaml
needYaml: true
copyToClipboard: true
savedFile: "compressed-code.txt"
compressService: true
doNotCompressPaths: [
  '_model.dart',
  '_facade.dart',
  '_state.dart',
  '_event.dart',
]
skipFiles: [
  '.freezed.dart',
  '.g.dart',
  '.res.dart',
  '/.',
]
includePaths: [
  lib/presentation,
  lib/domain,
  lib/data,
]
```

## Code Compression

When `compressService: true`, method bodies are replaced with `/* impl */` to significantly reduce token count while preserving:

- Class and method signatures
- Constructor definitions
- Field declarations
- Import statements
- Code structure and architecture

**Before compression:**
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthFacade _authFacade;

  AuthBloc(this._authFacade) : super(const AuthState.initial());

  Future<void> _onLogin(_Login event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginStatus: VarStatus.loading()));
    final result = await _authFacade.login(event.username, event.password);
    result.fold(
      (l) => emit(state.copyWith(loginStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(loginStatus: VarStatus.success())),
    );
  }
}
```

**After compression:**
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthFacade _authFacade;

  AuthBloc(this._authFacade) : super(const AuthState.initial());

  Future<void> _onLogin(_Login event, Emitter<AuthState> emit) async {
    /* impl */
  }
}
```

Use `doNotCompressPaths` to keep important files uncompressed (models, facades, states, events).

## Real-World Scenarios

**Scenario 1: New to the Team**
> You join a project with complex state management. Instead of bothering the tech lead, generate the prompt, paste it to Claude, and ask: "Explain this project's state management architecture and where I should add a new feature."

**Scenario 2: Stuck on a Task**
> Senior dev assigned you a refactoring task in an unfamiliar module. Generate the prompt for that specific path, ask AI: "How should I refactor this to follow clean architecture principles?"

**Scenario 3: Code Review Preparation**
> Before submitting a PR, generate your feature's code, ask AI: "Review this implementation for potential issues, edge cases, and best practices violations."

**Scenario 4: Large Codebase**
> Your project is too large for AI context limits. Enable `compressService: true` to reduce tokens by 40-60% while keeping full architecture visibility.

## Features

- One-command code collection
- Flexible path configuration
- Smart file filtering
- Optional clipboard integration
- Customizable output format
- No manual file copying
- Works with all AI assistants
- Code compression for token optimization

## Tips for Best Results

1. **Be Specific**: Include only relevant directories for your question
2. **Clean First**: Skip generated and test files to reduce noise
3. **Ask Clearly**: When pasting to AI, frame your question with context
4. **Iterate**: Regenerate with different paths for different questions
5. **Combine Tools**: Use with your AI assistant's other capabilities for maximum benefit
6. **Use Compression**: For large projects, enable `compressService` to fit more code in AI context

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

---

**Stop hesitating. Start shipping.** Let AI become your senior developer, architect, and code reviewer - all with full knowledge of YOUR project.