## 1.1.0

- 🎉 **Breaking Change**: Converted from Flutter package to pure Dart package
- ✨ Now supports both Flutter and pure Dart applications
- 🔧 Added `AssetLoader` abstraction for flexible asset loading
- 📦 Added `FileAssetLoader` for pure Dart applications (file system based)
- 📦 Added `FlutterAssetLoader` for Flutter applications (requires passing rootBundle)
- 🏢 Package now owned by MayR Labs organization
- 📝 Updated all repository URLs to MayR-Labs/mayr_dart_fake_api
- 📄 Updated LICENSE to MayR Labs (https://mayrlabs.com)
- 📚 Updated documentation to reflect Dart package usage
- 🎯 **Flutter is no longer a dependency** - completely removed from package dependencies

### Migration Guide

For Flutter apps, update your initialization to pass rootBundle to FlutterAssetLoader:

```dart
import 'package:flutter/services.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  assetLoader: FlutterAssetLoader(rootBundle), // Pass rootBundle
);
```

For pure Dart apps, the default FileAssetLoader works automatically:

```dart
await MayrFakeApi.init(
  basePath: 'path/to/api/files',
  attachTo: dio,
  // FileAssetLoader is used by default
);
```

## 1.0.0

- 🎉 Initial stable release
- ✨ Intercepts Dio HTTP requests and returns fake JSON responses from local assets
- 📁 Supports flexible directory structure for organizing fake API responses
- 🔄 Supports all HTTP methods (GET, POST, PUT, DELETE, etc.)
- 🌟 Dynamic path support with wildcards (e.g., `/user/-/profile`)
- 🔧 Placeholder replacement in JSON responses (`$1`, `$2`, `$timestamp`)
- 🎲 Built-in placeholder support: `$uuid` and `$ulid`
- 🔧 Custom placeholder functionality for user-defined dynamic values
- 📭 Automatic 204 No Content response for empty JSON files
- ⚠️ Error simulation with `error.json` files
- 🚫 Customizable 404 not found responses
- ⏱️ Configurable network delay simulation
- 🎛️ Enable/disable toggle for development/production
- 📚 Comprehensive documentation and examples
- ✅ Full test coverage
- 🐛 Fixed test suite bugs (corrected URL paths and data access patterns)
- 📦 Added `uuid` and `faker` package dependencies

## 0.0.1

- Initial release
