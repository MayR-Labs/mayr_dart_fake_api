# Contributing to mayr_fake_api

Thank you for considering contributing to `mayr_fake_api`! 🎉

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

1. **Clear title**: Brief description of the bug
2. **Description**: Detailed explanation of the issue
3. **Steps to reproduce**: How to reproduce the bug
4. **Expected behavior**: What you expected to happen
5. **Actual behavior**: What actually happened
6. **Environment**: Flutter version, Dart version, OS
7. **Code samples**: Minimal code to reproduce the issue

### Suggesting Features

We welcome feature suggestions! Please create an issue with:

1. **Clear title**: Brief description of the feature
2. **Use case**: Why this feature would be useful
3. **Proposed solution**: How you think it should work
4. **Alternatives**: Other ways to solve the problem

### Pull Requests

We love pull requests! Here's the process:

1. **Fork the repository**
2. **Create a branch**: `git checkout -b feature/my-feature`
3. **Make your changes**
4. **Add tests**: Ensure your code is tested
5. **Run tests**: `flutter test`
6. **Format code**: `dart format .`
7. **Analyze code**: `dart analyze`
8. **Commit**: Use clear commit messages
9. **Push**: `git push origin feature/my-feature`
10. **Create PR**: Open a pull request with a clear description

## Development Setup

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK (latest stable)
- Git

### Clone and Setup

```bash
git clone https://github.com/YoungMayor/mayr_dart_fake_api.git
cd mayr_dart_fake_api
flutter pub get
```

### Running Tests

```bash
flutter test
```

### Running the Example

```bash
cd example
flutter pub get
flutter run
```

## Code Style

We follow the official Dart style guide:

- Use `dart format` to format your code
- Follow naming conventions
- Add documentation comments for public APIs
- Keep functions small and focused
- Use meaningful variable names

### Documentation Comments

Add documentation comments for all public APIs:

```dart
/// Initializes the fake API.
///
/// The [basePath] specifies where the fake API files are located.
/// The [attachTo] is the Dio instance to attach the interceptor to.
///
/// Example:
/// ```dart
/// await MayrFakeApi.init(
///   basePath: 'assets/api',
///   attachTo: dio,
/// );
/// ```
static Future<void> init({...}) async {
  // Implementation
}
```

## Testing

### Writing Tests

- Add tests for all new features
- Add tests for bug fixes
- Ensure tests are clear and maintainable
- Use descriptive test names

Example:

```dart
test('returns 200 for successful response', () async {
  // Arrange
  await MayrFakeApi.init(
    basePath: 'test/assets/api',
    attachTo: dio,
  );

  // Act
  final response = await dio.get('/api/test');

  // Assert
  expect(response.statusCode, 200);
});
```

### Test Coverage

We aim for high test coverage. Please ensure your changes are well-tested.

## Project Structure

```
mayr_fake_api/
├── lib/
│   ├── mayr_fake_api.dart          # Main export file
│   └── src/
│       ├── mayr_fake_api.dart      # Core API class
│       ├── mayr_fake_interceptor.dart  # Dio interceptor
│       └── mayr_fake_response.dart # Response model
├── test/
│   ├── mayr_flutter_fake_api_test.dart  # Unit tests
│   ├── integration_test.dart       # Integration tests
│   └── assets/                     # Test assets
├── example/                        # Example application
├── doc/                           # Documentation
├── CHANGELOG.md                   # Version history
├── LICENSE                        # MIT License
└── README.md                      # Main documentation
```

## Commit Messages

Use clear, descriptive commit messages:

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

Examples:
```
feat: add support for PATCH method
fix: handle empty JSON files correctly
docs: update README with new examples
test: add integration tests for wildcards
```

## Release Process

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` with changes
3. Ensure all tests pass
4. Create a git tag: `git tag v1.0.0`
5. Push tag: `git push origin v1.0.0`
6. Publish to pub.dev: `flutter pub publish`

## Code Review

All submissions require code review. We'll review:

- Code quality and style
- Test coverage
- Documentation
- Performance implications
- Breaking changes

## Questions?

If you have questions, feel free to:

- Open an issue for discussion
- Ask in the pull request
- Contact the maintainers

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Keep discussions on topic

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing! 🚀
