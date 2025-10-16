import 'package:flutter/services.dart';
import 'asset_loader.dart';

/// Flutter asset bundle-based loader
/// This loader uses Flutter's rootBundle to load assets
class FlutterAssetLoader implements AssetLoader {
  /// Creates a new Flutter asset loader
  FlutterAssetLoader();

  @override
  Future<String> loadString(String path) async {
    return await rootBundle.loadString(path);
  }

  @override
  Future<bool> exists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }
}
