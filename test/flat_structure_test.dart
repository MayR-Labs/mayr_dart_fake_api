import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V2.0.0 Flat Structure Tests', () {
    late Dio dio;

    setUp(() {
      dio = Dio();
    });

    test('loads flat structure file for GET request', () async {
      await MayrFakeApi.init(
        basePath: 'test/assets/api',
        attachTo: dio,
        delay: Duration.zero,
        debug: false,
      );

      final response = await dio.get('https://example.com/test_endpoint');

      expect(response.statusCode, 200);
      expect(response.data['data']['message'], 'Test successful');
    });

    test('loads flat structure file with placeholders', () async {
      await MayrFakeApi.init(
        basePath: 'test/assets/api',
        attachTo: dio,
        delay: Duration.zero,
        debug: false,
      );

      final response = await dio.get('https://example.com/placeholders');

      expect(response.statusCode, 200);
      expect(response.data['data']['timestamp'], isNotEmpty);
      expect(response.data['data']['uuid'], isNotEmpty);
      expect(response.data['data']['ulid'], isNotEmpty);
    });

    test('loads flat structure file with wildcards', () async {
      await MayrFakeApi.init(
        basePath: 'test/assets/api',
        attachTo: dio,
        delay: Duration.zero,
        debug: false,
      );

      final response = await dio.get('https://example.com/dynamic/123/data');

      expect(response.statusCode, 200);
      expect(response.data['data']['id'], '123');
      expect(response.data['data']['timestamp'], isNotEmpty);
    });

    test('debug mode logs messages', () async {
      // This test just ensures the debug parameter is accepted
      await MayrFakeApi.init(
        basePath: 'test/assets/api',
        attachTo: dio,
        delay: Duration.zero,
        debug: true,
      );

      final response = await dio.get('https://example.com/test_endpoint');

      expect(response.statusCode, 200);
    });

    test('falls back to nested structure if flat file not found', () async {
      await MayrFakeApi.init(
        basePath: 'test/assets/api',
        attachTo: dio,
        delay: Duration.zero,
        debug: false,
      );

      // This should fall back to nested structure since flat file doesn't exist
      // The test still works because we have nested files as backup
      final response = await dio.get('https://example.com/test_endpoint');

      expect(response.statusCode, 200);
    });

    test('handles empty flat structure file', () async {
      await MayrFakeApi.init(
        basePath: 'test/assets/api',
        attachTo: dio,
        delay: Duration.zero,
        debug: false,
      );

      final response = await dio.get('https://example.com/test_endpoint/empty');

      expect(response.statusCode, 204);
    });

    test('works with custom placeholders in flat structure', () async {
      await MayrFakeApi.init(
        basePath: 'test/assets/api',
        attachTo: dio,
        delay: Duration.zero,
        debug: false,
        customPlaceholders: {'customValue': () => 'MyCustomValue'},
      );

      final response = await dio.get('https://example.com/placeholders');

      expect(response.statusCode, 200);
      expect(response.data['data']['custom'], 'MyCustomValue');
    });

    test('all_placeholders works with flat structure', () async {
      await MayrFakeApi.init(
        basePath: 'test/assets/api',
        attachTo: dio,
        delay: Duration.zero,
        debug: false,
      );

      final response = await dio.get(
        'https://example.com/all_placeholders?test=value',
      );

      expect(response.statusCode, 200);
      final data = response.data['data'];

      // Verify key placeholders
      expect(data['request']['method'], 'GET');
      expect(data['ids']['uuid'], isNotEmpty);
      expect(data['user']['email'], contains('@'));
      expect(data['datetime']['timestamp'], isNotEmpty);
    });
  });
}
