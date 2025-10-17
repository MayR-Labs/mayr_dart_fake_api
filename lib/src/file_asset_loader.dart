import 'dart:io';
import 'asset_loader.dart';

/// File system-based asset loader for pure Dart applications
/// This loader reads files from the file system directly
class FileAssetLoader implements AssetLoader {
  /// Base directory for assets
  final String baseDirectory;

  /// Creates a new file asset loader with the given base directory
  FileAssetLoader({required this.baseDirectory});

  @override
  Future<String> loadString(String path) async {
    final file = File('$baseDirectory/$path');
    return await file.readAsString();
  }

  @override
  Future<bool> exists(String path) async {
    final file = File('$baseDirectory/$path');
    return await file.exists();
  }
}
