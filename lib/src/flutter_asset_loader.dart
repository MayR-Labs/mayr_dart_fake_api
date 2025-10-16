import 'asset_loader.dart';

/// Flutter asset bundle-based loader
/// Uses Flutter's rootBundle to load assets
/// 
/// Usage:
/// ```dart
/// import 'package:flutter/services.dart';
/// import 'package:mayr_fake_api/mayr_fake_api.dart';
/// 
/// final loader = FlutterAssetLoader(rootBundle);
/// ```
class FlutterAssetLoader implements AssetLoader {
  /// The asset bundle to load from (typically rootBundle from Flutter)
  final dynamic rootBundle;

  /// Creates a new Flutter asset loader with the given rootBundle
  /// 
  /// [rootBundle] - The Flutter AssetBundle (import from 'package:flutter/services.dart')
  FlutterAssetLoader(this.rootBundle);

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
