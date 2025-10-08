import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'mayr_fake_response.dart';

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

  /// UUID generator instance
  static final _uuid = Uuid();
  
  /// Faker instance for generating fake data
  static final _faker = Faker();
  
  /// Random instance for random values
  static final _random = Random();

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

      // Replace placeholders
      final processedJson = _replacePlaceholders(json, wildcardValues, options);

      return MayrFakeResponse.fromJson(processedJson);
    } catch (e) {
      return null;
    }
  }

  /// Replaces placeholders in the response data
  Map<String, dynamic> _replacePlaceholders(
    Map<String, dynamic> json,
    List<String> wildcardValues,
    RequestOptions options,
  ) {
    final now = DateTime.now();
    final timestamp = now.toIso8601String();
    final uuid = _uuid.v4();
    final ulid = _generateUlid();
    
    // Extract request information
    final uri = Uri.parse(options.uri.toString());
    final method = options.method.toUpperCase();
    final path = uri.path;
    final queryParams = uri.queryParameters.toString();

    String processString(String value) {
      var result = value;

      // Replace built-in placeholders
      result = result.replaceAll(r'$timestamp', timestamp);
      result = result.replaceAll(r'$uuid', uuid);
      result = result.replaceAll(r'$ulid', ulid);
      
      // Request context placeholders
      result = result.replaceAll(r'$method', method);
      result = result.replaceAll(r'$path', path);
      result = result.replaceAll(r'$query', queryParams);
      
      // Date/Time placeholders
      result = result.replaceAll(r'$date', '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
      result = result.replaceAll(r'$time', '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}');
      result = result.replaceAll(r'$datetime', timestamp);
      result = result.replaceAll(r'$now', timestamp);
      
      // Network/IP placeholders
      result = result.replaceAll(r'$ipAddress', '${_random.nextInt(256)}.${_random.nextInt(256)}.${_random.nextInt(256)}.${_random.nextInt(256)}');
      
      // User-related placeholders
      result = result.replaceAll(r'$userId', _uuid.v4());
      result = result.replaceAll(r'$userEmail', _faker.internet.email());
      result = result.replaceAll(r'$username', _faker.internet.userName());
      result = result.replaceAll(r'$userFirstName', _faker.person.firstName());
      result = result.replaceAll(r'$userLastName', _faker.person.lastName());
      result = result.replaceAll(r'$userFullName', _faker.person.name());
      result = result.replaceAll(r'$userAvatar', 'https://i.pravatar.cc/150?u=${_uuid.v4()}');
      result = result.replaceAll(r'$userPhone', _faker.phoneNumber.us());
      result = result.replaceAll(r'$userToken', _generateToken());
      
      // Random data placeholders
      result = result.replaceAll(r'$id', _random.nextInt(999999).toString());
      result = result.replaceAll(r'$randomSentence', _faker.lorem.sentence());
      result = result.replaceAll(r'$randomWord', _faker.lorem.word());
      result = result.replaceAll(r'$randomBool', _random.nextBool().toString());
      
      // Location placeholders
      result = result.replaceAll(r'$country', _faker.address.country());
      result = result.replaceAll(r'$countryCode', _faker.address.countryCode());
      result = result.replaceAll(r'$city', _faker.address.city());
      result = result.replaceAll(r'$state', _faker.address.state());
      result = result.replaceAll(r'$address', _faker.address.streetAddress());
      result = result.replaceAll(r'$timezone', _faker.address.timeZone());
      
      // Business placeholders
      result = result.replaceAll(r'$currency', _faker.currency.code());
      result = result.replaceAll(r'$jobTitle', _faker.job.title());
      result = result.replaceAll(r'$companyName', _faker.company.name());
      result = result.replaceAll(r'$productName', _faker.food.dish());
      result = result.replaceAll(r'$sku', 'SKU-${_random.nextInt(99999).toString().padLeft(5, '0')}');
      
      // Color/Design placeholders
      result = result.replaceAll(r'$hexColor', '#${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}');
      result = result.replaceAll(r'$color', _faker.color.commonColor());
      
      // Other placeholders
      result = result.replaceAll(r'$version', '${_random.nextInt(10)}.${_random.nextInt(20)}.${_random.nextInt(50)}');
      result = result.replaceAll(r'$statusCode', '200');
      result = result.replaceAll(r'$hash', _generateHash());
      result = result.replaceAll(r'$shortId', _generateShortId());
      
      // Handle parameterized placeholders
      result = _replaceParameterizedPlaceholders(result);

      // Replace custom placeholders
      for (final entry in customPlaceholders.entries) {
        result = result.replaceAll('\$${entry.key}', entry.value());
      }

      // Replace $1, $2, $3, etc.
      for (var i = 0; i < wildcardValues.length; i++) {
        result = result.replaceAll('\$${i + 1}', wildcardValues[i]);
      }

      return result;
    }

    dynamic processValue(dynamic value) {
      if (value is String) {
        return processString(value);
      } else if (value is Map<String, dynamic>) {
        return value.map((key, val) => MapEntry(key, processValue(val)));
      } else if (value is List) {
        return value.map(processValue).toList();
      }
      return value;
    }

    return json.map((key, value) => MapEntry(key, processValue(value)));
  }
  
  /// Handles parameterized placeholders like $randomInt(min,max)
  String _replaceParameterizedPlaceholders(String value) {
    var result = value;
    
    // $randomInt(min,max)
    final randomIntPattern = RegExp(r'\$randomInt\((\d+),(\d+)\)');
    result = result.replaceAllMapped(randomIntPattern, (match) {
      final min = int.parse(match.group(1)!);
      final max = int.parse(match.group(2)!);
      return (min + _random.nextInt(max - min + 1)).toString();
    });
    
    // $randomFloat(min,max)
    final randomFloatPattern = RegExp(r'\$randomFloat\((\d+\.?\d*),(\d+\.?\d*)\)');
    result = result.replaceAllMapped(randomFloatPattern, (match) {
      final min = double.parse(match.group(1)!);
      final max = double.parse(match.group(2)!);
      return (min + _random.nextDouble() * (max - min)).toStringAsFixed(2);
    });
    
    // $choose(a,b,c,...)
    final choosePattern = RegExp(r'\$choose\(([^)]+)\)');
    result = result.replaceAllMapped(choosePattern, (match) {
      final options = match.group(1)!.split(',').map((e) => e.trim()).toList();
      return options[_random.nextInt(options.length)];
    });
    
    // $image(width,height)
    final imagePattern = RegExp(r'\$image\((\d+),(\d+)\)');
    result = result.replaceAllMapped(imagePattern, (match) {
      final width = match.group(1);
      final height = match.group(2);
      return 'https://via.placeholder.com/${width}x$height';
    });
    
    return result;
  }
  
  /// Generates a secure token
  String _generateToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(64, (index) => chars[_random.nextInt(chars.length)]).join();
  }
  
  /// Generates a hash
  String _generateHash() {
    return List.generate(40, (index) => _random.nextInt(16).toRadixString(16)).join();
  }
  
  /// Generates a short ID
  String _generateShortId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(8, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Generates a ULID (Universally Unique Lexicographically Sortable Identifier)
  /// Format: 26 characters (10 timestamp + 16 random)
  String _generateUlid() {
    const alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random();
    
    // Encode timestamp (48 bits / 10 characters)
    var timestampPart = '';
    var time = timestamp;
    for (var i = 0; i < 10; i++) {
      timestampPart = alphabet[time % 32] + timestampPart;
      time = time ~/ 32;
    }
    
    // Generate random part (80 bits / 16 characters)
    var randomPart = '';
    for (var i = 0; i < 16; i++) {
      randomPart += alphabet[random.nextInt(32)];
    }
    
    return timestampPart + randomPart;
  }
}
