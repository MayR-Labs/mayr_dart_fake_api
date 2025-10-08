import 'dart:math';
import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:uuid/uuid.dart';

/// Utility class for handling placeholder replacement in fake API responses
class PlaceholderReplacer {
  /// UUID generator instance
  static final _uuid = Uuid();
  
  /// Faker instance for generating fake data
  static final _faker = Faker();
  
  /// Random instance for random values
  static final _random = Random();

  /// Replaces placeholders in the response data
  static Map<String, dynamic> replacePlaceholders(
    Map<String, dynamic> json,
    List<String> wildcardValues,
    RequestOptions options,
    Map<String, String Function()> customPlaceholders,
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
      result = result.replaceAll(r'$timezone', _generateTimeZone());
      
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
  static String _replaceParameterizedPlaceholders(String value) {
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
  static String _generateToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(64, (index) => chars[_random.nextInt(chars.length)]).join();
  }
  
  /// Generates a hash
  static String _generateHash() {
    return List.generate(40, (index) => _random.nextInt(16).toRadixString(16)).join();
  }
  
  /// Generates a short ID
  static String _generateShortId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(8, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Generates a ULID (Universally Unique Lexicographically Sortable Identifier)
  /// Format: 26 characters (10 timestamp + 16 random)
  static String _generateUlid() {
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

  /// Generates a random timezone
  static String _generateTimeZone() {
    const timezones = [
      'America/New_York',
      'America/Chicago',
      'America/Denver',
      'America/Los_Angeles',
      'America/Anchorage',
      'Pacific/Honolulu',
      'Europe/London',
      'Europe/Paris',
      'Europe/Berlin',
      'Europe/Rome',
      'Europe/Madrid',
      'Europe/Amsterdam',
      'Asia/Tokyo',
      'Asia/Shanghai',
      'Asia/Hong_Kong',
      'Asia/Singapore',
      'Asia/Dubai',
      'Asia/Kolkata',
      'Australia/Sydney',
      'Australia/Melbourne',
      'Australia/Brisbane',
      'Africa/Cairo',
      'Africa/Johannesburg',
      'America/Sao_Paulo',
      'America/Mexico_City',
      'America/Toronto',
      'Pacific/Auckland',
    ];
    return timezones[_random.nextInt(timezones.length)];
  }
}
