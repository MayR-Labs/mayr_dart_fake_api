// ignore_for_file: avoid_print

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

  /// Whether debug logging is enabled
  final bool debug;

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
    this.debug = false,
    this.resolveNotFound,
    Map<String, String Function()>? customPlaceholders,
  }) : customPlaceholders = customPlaceholders ?? {};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!enabled) {
      if (debug) {
        print('[MayrFakeApi] Interceptor disabled, passing request through');
      }
      return handler.next(options);
    }

    if (debug) {
      print(
        '[MayrFakeApi] Intercepting request: ${options.method} ${options.uri}',
      );
    }

    try {
      // Simulate delay
      if (delay.inMilliseconds > 0) {
        if (debug) {
          print(
            '[MayrFakeApi] Simulating network delay: ${delay.inMilliseconds}ms',
          );
        }
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

      if (debug) {
        print('[MayrFakeApi] Request path: $requestPath');
        print('[MayrFakeApi] HTTP method: $method');
      }

      // Try to load the response
      final response = await _loadResponse(requestPath, method, options);

      if (response != null) {
        if (debug) {
          print(
            '[MayrFakeApi] Found response with status code: ${response.statusCode}',
          );
        }

        // Check if it's an error response
        if (response.statusCode >= 400) {
          if (debug) {
            print('[MayrFakeApi] Returning error response');
          }
          return handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: response.statusCode,
                data: response.body,
                headers: response.headers != null
                    ? Headers.fromMap(
                        response.headers!.map(
                          (key, value) => MapEntry(key, [value.toString()]),
                        ),
                      )
                    : Headers(),
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        }

        // Return successful response
        if (debug) {
          print('[MayrFakeApi] Returning successful response');
        }
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: response.statusCode,
            // Expose full JSON structure for backward compatibility
            // V2.0: response.data['body'] contains the actual response body
            // V1.x: response.data['data'] still works via the legacy getter
            data: {
              'statusCode': response.statusCode,
              'body': response.body,
              'data': response.body, // Legacy support
              if (response.headers != null) 'headers': response.headers,
              if (response.cookies != null) 'cookies': response.cookies,
            },
            headers: response.headers != null
                ? Headers.fromMap(
                    response.headers!.map(
                      (key, value) => MapEntry(key, [value.toString()]),
                    ),
                  )
                : Headers(),
          ),
        );
      }

      if (debug) {
        print('[MayrFakeApi] No fake response found, returning 404');
      }

      // File not found, use custom resolver or default 404
      final notFoundResponse =
          resolveNotFound?.call(requestPath, method) ??
          const MayrFakeResponse(statusCode: 404, body: {'error': 'Not found'});

      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: notFoundResponse.statusCode,
            data: notFoundResponse.body,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
    } catch (e) {
      if (debug) {
        print('[MayrFakeApi] Error occurred: $e, passing request through');
      }
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
    // Try flat structure first (v2.0.0+)
    // Convert path like "user/profile" to "user.profile.get.json"
    final flatPath = _convertToFlatPath(requestPath, method);
    if (debug) {
      print('[MayrFakeApi] Trying flat structure: $flatPath');
    }
    final flatResponse = await _tryLoadFile(flatPath, [], options);

    if (flatResponse != null) {
      if (debug) {
        print('[MayrFakeApi] Loaded from flat structure: $flatPath');
      }
      return flatResponse;
    }

    // Try flat structure with dynamic paths (wildcards)
    if (debug) {
      print('[MayrFakeApi] Trying flat structure with wildcards');
    }
    final parts = requestPath.split('/');
    final flatWildcardResponse = await _tryFlatWithWildcards(
      parts,
      method,
      0,
      [],
      options,
    );

    if (flatWildcardResponse != null) {
      if (debug) {
        print('[MayrFakeApi] Loaded from flat structure with wildcards');
      }
      return flatWildcardResponse;
    }

    // Try flat error structure
    final flatErrorPath = _convertToFlatPath(requestPath, 'error');
    if (debug) {
      print('[MayrFakeApi] Trying flat error structure: $flatErrorPath');
    }
    final flatErrorResponse = await _tryLoadFile(flatErrorPath, [], options);

    if (flatErrorResponse != null && flatErrorResponse.statusCode >= 400) {
      if (debug) {
        print('[MayrFakeApi] Loaded error from flat structure: $flatErrorPath');
      }
      return flatErrorResponse;
    }

    // Fallback to nested structure for backwards compatibility (v1.x)
    if (debug) {
      print('[MayrFakeApi] Trying nested structure (v1.x fallback)');
    }
    // Try exact path first
    final exactPath = p.join(basePath, requestPath, '$method.json');
    final exactResponse = await _tryLoadFile(exactPath, [], options);

    if (exactResponse != null) {
      if (debug) {
        print('[MayrFakeApi] Loaded from nested structure: $exactPath');
      }
      return exactResponse;
    }

    // Try with dynamic paths (wildcards)
    final wildcardResponse = await _tryWithWildcards(
      parts,
      method,
      0,
      [],
      options,
    );

    if (wildcardResponse != null) {
      if (debug) {
        print('[MayrFakeApi] Loaded from nested structure with wildcards');
      }
      return wildcardResponse;
    }

    // Try error.json
    final errorPath = p.join(basePath, requestPath, 'error.json');
    final errorResponse = await _tryLoadFile(errorPath, [], options);

    if (errorResponse != null && errorResponse.statusCode >= 400) {
      if (debug) {
        print('[MayrFakeApi] Loaded error from nested structure: $errorPath');
      }
      return errorResponse;
    }

    if (debug) {
      print('[MayrFakeApi] No matching file found');
    }
    return null;
  }

  /// Converts a path to flat structure
  /// e.g., "user/profile" + "get" -> "basePath/user.profile.get.json"
  String _convertToFlatPath(String requestPath, String method) {
    if (requestPath.isEmpty) {
      return p.join(basePath, '$method.json');
    }
    final flatPath = requestPath.replaceAll('/', '.');
    return p.join(basePath, '$flatPath.$method.json');
  }

  /// Recursively tries flat paths with wildcards
  Future<MayrFakeResponse?> _tryFlatWithWildcards(
    List<String> parts,
    String method,
    int index,
    List<String> wildcardValues,
    RequestOptions options,
  ) async {
    if (index >= parts.length) {
      final flatPath = _convertToFlatPath(parts.join('/'), method);
      return await _tryLoadFile(flatPath, wildcardValues, options);
    }

    // Try with the original part first
    final originalResponse = await _tryFlatWithWildcards(
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
    final wildcardResponse = await _tryFlatWithWildcards(
      parts,
      method,
      index + 1,
      [...wildcardValues, originalPart],
      options,
    );
    parts[index] = originalPart; // Restore original

    return wildcardResponse;
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
