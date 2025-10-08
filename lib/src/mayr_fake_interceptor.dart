import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'mayr_fake_response.dart';
import 'placeholder_replacer.dart';

/// Interceptor for Dio that intercepts requests and returns fake responses
class MayrFakeInterceptor extends Interceptor {
  /// Base path for fake API assets
  final String basePath;

  /// Delay to simulate network latency
  final Duration delay;

  /// Whether the interceptor is enabled
  final bool enabled;

  /// Custom resolver for not found endpoints
  final MayrFakeResponse Function(String path, String method)? resolveNotFound;

  /// Custom placeholder resolvers
  /// Map of placeholder names (without $) to resolver functions
  final Map<String, String Function()> customPlaceholders;

  /// Creates a new interceptor
  MayrFakeInterceptor({
    required this.basePath,
    this.delay = const Duration(milliseconds: 500),
    this.enabled = true,
    this.resolveNotFound,
    Map<String, String Function()>? customPlaceholders,
  }) : customPlaceholders = customPlaceholders ?? {};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!enabled) {
      return handler.next(options);
    }

    try {
      // Simulate delay
      if (delay.inMilliseconds > 0) {
        await Future.delayed(delay);
      }

      // Extract path from URL
      final uri = Uri.parse(options.uri.toString());
      String requestPath = uri.path;

      // Remove leading slash if present
      if (requestPath.startsWith('/')) {
        requestPath = requestPath.substring(1);
      }

      // Get the HTTP method
      final method = options.method.toLowerCase();

      // Try to load the response
      final response = await _loadResponse(requestPath, method, options);

      if (response != null) {
        // Check if it's an error response
        if (response.statusCode >= 400) {
          return handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: response.statusCode,
                data: response.data,
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        }

        // Return successful response
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: response.statusCode,
            data: response.data,
          ),
        );
      }

      // File not found, use custom resolver or default 404
      final notFoundResponse =
          resolveNotFound?.call(requestPath, method) ??
          const MayrFakeResponse(statusCode: 404, data: {'error': 'Not found'});

      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: notFoundResponse.statusCode,
            data: notFoundResponse.data,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
    } catch (e) {
      // If something goes wrong, let the request continue normally
      return handler.next(options);
    }
  }

  /// Loads a response from assets
  Future<MayrFakeResponse?> _loadResponse(
    String requestPath,
    String method,
    RequestOptions options,
  ) async {
    // Try exact path first
    final exactPath = p.join(basePath, requestPath, '$method.json');
    final exactResponse = await _tryLoadFile(exactPath, [], options);

    if (exactResponse != null) {
      return exactResponse;
    }

    // Try with dynamic paths (wildcards)
    final parts = requestPath.split('/');
    final wildcardResponse = await _tryWithWildcards(parts, method, 0, [], options);

    if (wildcardResponse != null) {
      return wildcardResponse;
    }

    // Try error.json
    final errorPath = p.join(basePath, requestPath, 'error.json');
    final errorResponse = await _tryLoadFile(errorPath, [], options);

    if (errorResponse != null && errorResponse.statusCode >= 400) {
      return errorResponse;
    }

    return null;
  }

  /// Recursively tries paths with wildcards
  Future<MayrFakeResponse?> _tryWithWildcards(
    List<String> parts,
    String method,
    int index,
    List<String> wildcardValues,
    RequestOptions options,
  ) async {
    if (index >= parts.length) {
      final path = p.join(basePath, parts.join('/'), '$method.json');
      return await _tryLoadFile(path, wildcardValues, options);
    }

    // Try with the original part first
    final originalResponse = await _tryWithWildcards(
      parts,
      method,
      index + 1,
      wildcardValues,
      options,
    );

    if (originalResponse != null) {
      return originalResponse;
    }

    // Try with wildcard
    final originalPart = parts[index];
    parts[index] = '-';
    final wildcardResponse = await _tryWithWildcards(parts, method, index + 1, [
      ...wildcardValues,
      originalPart,
    ], options);
    parts[index] = originalPart; // Restore original

    return wildcardResponse;
  }

  /// Tries to load a file from assets
  Future<MayrFakeResponse?> _tryLoadFile(
    String path,
    List<String> wildcardValues,
    RequestOptions options,
  ) async {
    try {
      final content = await rootBundle.loadString(path);

      // Handle empty files (204 No Content)
      if (content.trim().isEmpty) {
        return const MayrFakeResponse(statusCode: 204);
      }

      // Parse JSON
      final json = jsonDecode(content) as Map<String, dynamic>;

      // Replace placeholders using PlaceholderReplacer utility
      final processedJson = PlaceholderReplacer.replacePlaceholders(
        json,
        wildcardValues,
        options,
        customPlaceholders,
      );

      return MayrFakeResponse.fromJson(processedJson);
    } catch (e) {
      return null;
    }
  }
}
