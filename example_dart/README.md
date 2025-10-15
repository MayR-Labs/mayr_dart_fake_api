# Pure Dart Example

This example demonstrates using `mayr_fake_api` with pure Dart (no Flutter dependency).

## Running the Example

1. Make sure you have Dart installed
2. Navigate to this directory:
   ```bash
   cd example_dart
   ```
3. Get dependencies:
   ```bash
   dart pub get
   ```
4. Run the example:
   ```bash
   dart run
   ```

## What This Example Demonstrates

This example shows how to use `mayr_fake_api` in a pure Dart application without any Flutter dependencies:

1. **Simple GET request** - Loads user list from `assets/api/users.get.json`
2. **POST request** - Creates a user using `assets/api/users.post.json`
3. **Dynamic route** - Gets a specific user using wildcard pattern in `assets/api/users.-.get.json`
4. **404 handling** - Shows what happens when an endpoint doesn't exist

## Key Differences from Flutter

- No need to use `WidgetsFlutterBinding.ensureInitialized()`
- No need to import Flutter packages
- Asset files are loaded directly from the filesystem using `DartAssetLoader`
- No need to configure assets in `pubspec.yaml` (files are accessed directly)

## Asset Structure

```
example_dart/
  assets/
    api/
      users.get.json        # GET /users
      users.post.json       # POST /users
      users.-.get.json      # GET /users/{id} (dynamic)
```

## Notes

- The package defaults to `DartAssetLoader()` when used in pure Dart
- Files are loaded from the filesystem relative to the working directory
- Perfect for CLI tools, servers, and non-Flutter applications
