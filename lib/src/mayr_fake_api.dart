// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'asset_loader.dart';
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
  /// [debug] - Whether to enable debug logging (default: false)
  /// [resolveNotFound] - Custom resolver for not found endpoints
  /// [customPlaceholders] - Map of custom placeholder names to resolver functions
  /// [assetLoader] - Custom asset loader (optional, defaults to DartAssetLoader for pure Dart or FlutterAssetLoader for Flutter)
  static Future<void> init({
    required String basePath,
    required Dio attachTo,
    Duration delay = const Duration(milliseconds: 500),
    bool enabled = true,
    bool debug = false,
    MayrFakeResponse Function(String path, String method)? resolveNotFound,
    Map<String, String Function()>? customPlaceholders,
    AssetLoader? assetLoader,
  }) async {
    _interceptor = MayrFakeInterceptor(
      basePath: basePath,
      delay: delay,
      enabled: enabled,
      debug: debug,
      resolveNotFound: resolveNotFound,
      customPlaceholders: customPlaceholders,
      assetLoader: assetLoader,
    );

    attachTo.interceptors.add(_interceptor!);

    if (debug) {
      print(
        '[MayrFakeApi] Initialized with basePath: $basePath, enabled: $enabled, delay: ${delay.inMilliseconds}ms',
      );
    }
  }

  /// Sets a custom resolver for not found endpoints
  static void resolveNotFound(
    MayrFakeResponse Function(String path, String method) resolver,
  ) {
    if (_interceptor != null) {
      _interceptor = MayrFakeInterceptor(
        basePath: _interceptor!.basePath,
        delay: _interceptor!.delay,
        enabled: _interceptor!.enabled,
        debug: _interceptor!.debug,
        resolveNotFound: resolver,
        customPlaceholders: _interceptor!.customPlaceholders,
        assetLoader: _interceptor!.assetLoader,
      );
    }
  }

  /// Disables the fake API
  static void disable() {
    if (_interceptor != null) {
      _interceptor = MayrFakeInterceptor(
        basePath: _interceptor!.basePath,
        delay: _interceptor!.delay,
        enabled: false,
        debug: _interceptor!.debug,
        resolveNotFound: _interceptor!.resolveNotFound,
        customPlaceholders: _interceptor!.customPlaceholders,
        assetLoader: _interceptor!.assetLoader,
      );
    }
  }

  /// Enables the fake API
  static void enable() {
    if (_interceptor != null) {
      _interceptor = MayrFakeInterceptor(
        basePath: _interceptor!.basePath,
        delay: _interceptor!.delay,
        enabled: true,
        debug: _interceptor!.debug,
        resolveNotFound: _interceptor!.resolveNotFound,
        customPlaceholders: _interceptor!.customPlaceholders,
        assetLoader: _interceptor!.assetLoader,
      );
    }
  }
}
