# Migration Guide: v1.0.0 to v1.1.0

## Overview

Version 1.1.0 converts `mayr_fake_api` from a Flutter-only package to a pure Dart package that works with both Flutter and pure Dart applications.

## What Changed?

### Package Structure
- **Before**: Required Flutter SDK
- **After**: Works with both Flutter and pure Dart (Flutter is now optional)

### Asset Loading
- **Before**: Used `rootBundle.loadString()` from Flutter's services
- **After**: Uses an abstraction layer with two implementations:
  - `FlutterAssetLoader`: For Flutter apps (uses `rootBundle`)
  - `FileAssetLoader`: For pure Dart apps (uses file system)

## Migration Steps

### For Flutter Apps

**Before (v1.0.0):**
```dart
await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
);
```

**After (v1.1.0):**
```dart
import 'package:mayr_fake_api/mayr_fake_api.dart';

await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  assetLoader: FlutterAssetLoader(), // Add this line
);
```

You still need to register assets in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/api/
    - assets/api/user/
    # ... other directories
```

### For Pure Dart Apps

**New in v1.1.0:**
```dart
import 'package:mayr_fake_api/mayr_fake_api.dart';

await MayrFakeApi.init(
  basePath: 'api_mocks',  // File system path
  attachTo: dio,
  assetLoader: FileAssetLoader(baseDirectory: 'api_mocks'),
);
```

For pure Dart apps:
- `basePath` should be a directory path on your file system
- No need to register assets in `pubspec.yaml`
- JSON files are loaded directly from the file system

## New Features

### Asset Loader Abstraction
Three new classes are exported:
- `AssetLoader`: Abstract interface
- `FlutterAssetLoader`: Flutter implementation
- `FileAssetLoader`: Pure Dart implementation

You can also create custom loaders by implementing the `AssetLoader` interface.

## Package Metadata Updates

- Package now owned by **MayR Labs**
- All URLs updated to `MayR-Labs/mayr_dart_fake_api`
- LICENSE updated to MayR Labs (https://mayrlabs.com)

## Breaking Changes

**⚠️ Important**: You must explicitly pass an `assetLoader` parameter when using Flutter apps.

If you don't provide an `assetLoader`, the package will default to `FileAssetLoader`, which will fail in Flutter apps because it tries to load from the file system instead of the asset bundle.

## Examples

Check out the examples:
- **Flutter**: See `/example` directory
- **Pure Dart**: See `/example_dart` directory

## Need Help?

- [GitHub Issues](https://github.com/MayR-Labs/mayr_dart_fake_api/issues)
- [Documentation](https://github.com/MayR-Labs/mayr_dart_fake_api/wiki)
