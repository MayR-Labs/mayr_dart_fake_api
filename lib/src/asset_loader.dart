import 'dart:io';

/// Abstract interface for loading assets
/// This allows the package to work with both Flutter and pure Dart applications
abstract class AssetLoader {
  /// Loads a string from the given asset path
  Future<String> loadString(String path);
}

/// Asset loader for pure Dart applications
/// Loads files directly from the filesystem
class DartAssetLoader implements AssetLoader {
  @override
  Future<String> loadString(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Asset not found: $path');
    }
    return await file.readAsString();
  }
}

/// Asset loader for Flutter applications
/// Uses Flutter's rootBundle to load assets
class FlutterAssetLoader implements AssetLoader {
  final dynamic rootBundle;

  FlutterAssetLoader(this.rootBundle);

  @override
  Future<String> loadString(String path) async {
    return await rootBundle.loadString(path);
  }
}
