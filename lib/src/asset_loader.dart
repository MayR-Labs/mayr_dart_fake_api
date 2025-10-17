/// Abstract interface for loading assets
/// This allows the package to work in both Flutter and pure Dart environments
abstract class AssetLoader {
  /// Loads a string from the given path
  /// Returns the content as a string or throws an exception if not found
  Future<String> loadString(String path);

  /// Checks if an asset exists at the given path
  Future<bool> exists(String path);
}
