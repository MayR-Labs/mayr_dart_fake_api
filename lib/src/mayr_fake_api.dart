import 'package:dio/dio.dart';
import 'asset_loader.dart';
import 'file_asset_loader.dart';
import 'mayr_fake_interceptor.dart';
import 'mayr_fake_response.dart';

/// Main class for initializing and configuring the fake API
class MayrFakeApi {
  static MayrFakeInterceptor? _interceptor;

  /// Initializes the fake API and attaches it to a Dio instance
  ///
  /// [basePath] - Base path for fake API assets (e.g., 'assets/api')
  /// [attachTo] - Dio instance to attach the interceptor to
  /// [delay] - Delay to simulate network latency (default: 500ms)
  /// [enabled] - Whether the fake API is enabled (default: true)
  /// [resolveNotFound] - Custom resolver for not found endpoints
  /// [customPlaceholders] - Map of custom placeholder names to resolver functions
  /// [assetLoader] - Custom asset loader. If not provided:
  ///   - In Flutter apps: Use FlutterAssetLoader() and pass it explicitly
  ///   - In Dart apps: Uses FileAssetLoader with basePath as directory
  static Future<void> init({
    required String basePath,
    required Dio attachTo,
    Duration delay = const Duration(milliseconds: 500),
    bool enabled = true,
    MayrFakeResponse Function(String path, String method)? resolveNotFound,
    Map<String, String Function()>? customPlaceholders,
    AssetLoader? assetLoader,
  }) async {
    // Use provided asset loader or default to file-based loader
    final loader = assetLoader ?? FileAssetLoader(baseDirectory: basePath);

    _interceptor = MayrFakeInterceptor(
      basePath: basePath,
      assetLoader: loader,
      delay: delay,
      enabled: enabled,
      resolveNotFound: resolveNotFound,
      customPlaceholders: customPlaceholders,
    );

    attachTo.interceptors.add(_interceptor!);
  }

  /// Sets a custom resolver for not found endpoints
  static void resolveNotFound(
    MayrFakeResponse Function(String path, String method) resolver,
  ) {
    if (_interceptor != null) {
      _interceptor = MayrFakeInterceptor(
        basePath: _interceptor!.basePath,
        assetLoader: _interceptor!.assetLoader,
        delay: _interceptor!.delay,
        enabled: _interceptor!.enabled,
        resolveNotFound: resolver,
        customPlaceholders: _interceptor!.customPlaceholders,
      );
    }
  }

  /// Disables the fake API
  static void disable() {
    if (_interceptor != null) {
      _interceptor = MayrFakeInterceptor(
        basePath: _interceptor!.basePath,
        assetLoader: _interceptor!.assetLoader,
        delay: _interceptor!.delay,
        enabled: false,
        resolveNotFound: _interceptor!.resolveNotFound,
        customPlaceholders: _interceptor!.customPlaceholders,
      );
    }
  }

  /// Enables the fake API
  static void enable() {
    if (_interceptor != null) {
      _interceptor = MayrFakeInterceptor(
        basePath: _interceptor!.basePath,
        assetLoader: _interceptor!.assetLoader,
        delay: _interceptor!.delay,
        enabled: true,
        resolveNotFound: _interceptor!.resolveNotFound,
        customPlaceholders: _interceptor!.customPlaceholders,
      );
    }
  }
}
