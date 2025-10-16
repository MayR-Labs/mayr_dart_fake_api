import 'package:dio/dio.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

/// Simple example of using mayr_fake_api with pure Dart (no Flutter)
void main() async {
  print('🧪 MayrFakeApi Pure Dart Example\n');

  // Create Dio instance
  final dio = Dio();

  // Initialize MayrFakeApi with DartAssetLoader (for filesystem access)
  await MayrFakeApi.init(
    basePath: 'assets/api',
    attachTo: dio,
    delay: Duration(milliseconds: 500),
    debug: true,
    // assetLoader defaults to DartAssetLoader() for pure Dart
  );

  print('Making API requests...\n');

  // Example 1: Simple GET request
  try {
    print('1. GET /users');
    final response = await dio.get('https://api.example.com/users');
    print('   Status: ${response.statusCode}');
    print('   Data: ${response.data}\n');
  } catch (e) {
    print('   Error: $e\n');
  }

  // Example 2: POST request
  try {
    print('2. POST /users');
    final response = await dio.post('https://api.example.com/users');
    print('   Status: ${response.statusCode}');
    print('   Data: ${response.data}\n');
  } catch (e) {
    print('   Error: $e\n');
  }

  // Example 3: Dynamic route with wildcard
  try {
    print('3. GET /users/123');
    final response = await dio.get('https://api.example.com/users/123');
    print('   Status: ${response.statusCode}');
    print('   Data: ${response.data}\n');
  } catch (e) {
    print('   Error: $e\n');
  }

  // Example 4: Not found endpoint
  try {
    print('4. GET /nonexistent');
    final response = await dio.get('https://api.example.com/nonexistent');
    print('   Status: ${response.statusCode}');
    print('   Data: ${response.data}\n');
  } catch (e) {
    print('   Error: Expected 404 - endpoint not found\n');
  }

  print('✅ Done! All examples completed.');
}
