import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MayrFakeResponse', () {
    test('creates response with required parameters', () {
      const response = MayrFakeResponse(
        statusCode: 200,
        body: {'key': 'value'},
      );

      expect(response.statusCode, 200);
      expect(response.body, {'key': 'value'});
      expect(response.data, {'key': 'value'}); // Legacy getter
    });

    test('creates response from JSON with body (v2.0)', () {
      final json = {
        'statusCode': 201,
        'body': {'id': 1, 'name': 'Test'},
        'headers': {'Content-Type': 'application/json'},
        'cookies': {'session': 'abc123'},
      };

      final response = MayrFakeResponse.fromJson(json);

      expect(response.statusCode, 201);
      expect(response.body, {'id': 1, 'name': 'Test'});
      expect(response.headers, {'Content-Type': 'application/json'});
      expect(response.cookies, {'session': 'abc123'});
    });

    test('creates response from JSON with data (v1.x compatibility)', () {
      final json = {
        'statusCode': 201,
        'data': {'id': 1, 'name': 'Test'},
      };

      final response = MayrFakeResponse.fromJson(json);

      expect(response.statusCode, 201);
      expect(response.body, {'id': 1, 'name': 'Test'});
      expect(response.data, {'id': 1, 'name': 'Test'}); // Legacy getter
    });

    test('creates response from JSON with default statusCode', () {
      final json = {
        'body': {'id': 1},
      };

      final response = MayrFakeResponse.fromJson(json);

      expect(response.statusCode, 200);
      expect(response.body, {'id': 1});
    });

    test('converts response to JSON', () {
      const response = MayrFakeResponse(
        statusCode: 204,
        body: null,
        headers: {'X-Custom': 'value'},
      );

      final json = response.toJson();

      expect(json['statusCode'], 204);
      expect(json['body'], null);
      expect(json['headers'], {'X-Custom': 'value'});
    });

    test('omits null headers and cookies from JSON', () {
      const response = MayrFakeResponse(
        statusCode: 200,
        body: {'test': 'data'},
      );

      final json = response.toJson();

      expect(json.containsKey('headers'), false);
      expect(json.containsKey('cookies'), false);
    });
  });

  group('MayrFakeApi', () {
    late Dio dio;

    setUp(() {
      dio = Dio();
    });

    test('initializes with required parameters', () async {
      await MayrFakeApi.init(basePath: 'assets/api', attachTo: dio);

      expect(dio.interceptors.length, greaterThan(0));
    });

    test('initializes with custom delay', () async {
      await MayrFakeApi.init(
        basePath: 'assets/api',
        attachTo: dio,
        delay: const Duration(milliseconds: 100),
      );

      expect(dio.interceptors.length, greaterThan(0));
    });

    test('initializes with enabled flag', () async {
      await MayrFakeApi.init(
        basePath: 'assets/api',
        attachTo: dio,
        enabled: false,
      );

      expect(dio.interceptors.length, greaterThan(0));
    });

    test('initializes with custom not found resolver', () async {
      await MayrFakeApi.init(
        basePath: 'assets/api',
        attachTo: dio,
        resolveNotFound: (path, method) {
          return const MayrFakeResponse(
            statusCode: 404,
            body: {'error': 'Custom not found'},
          );
        },
      );

      expect(dio.interceptors.length, greaterThan(0));
    });
  });

  group('MayrFakeInterceptor', () {
    test('creates interceptor with required parameters', () {
      final interceptor = MayrFakeInterceptor(basePath: 'assets/api');

      expect(interceptor.basePath, 'assets/api');
      expect(interceptor.delay, const Duration(milliseconds: 500));
      expect(interceptor.enabled, true);
    });

    test('creates interceptor with custom parameters', () {
      final interceptor = MayrFakeInterceptor(
        basePath: 'test/assets/api',
        delay: const Duration(milliseconds: 100),
        enabled: false,
      );

      expect(interceptor.basePath, 'test/assets/api');
      expect(interceptor.delay, const Duration(milliseconds: 100));
      expect(interceptor.enabled, false);
    });

    test('creates interceptor with custom not found resolver', () {
      final interceptor = MayrFakeInterceptor(
        basePath: 'assets/api',
        resolveNotFound: (path, method) {
          return const MayrFakeResponse(
            statusCode: 404,
            body: {'error': 'Custom error'},
          );
        },
      );

      expect(interceptor.resolveNotFound, isNotNull);
    });
  });
}
