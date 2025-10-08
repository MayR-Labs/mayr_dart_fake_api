import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MayrFakeResponse', () {
    test('creates response with required parameters', () {
      const response = MayrFakeResponse(
        statusCode: 200,
        data: {'key': 'value'},
      );

      expect(response.statusCode, 200);
      expect(response.data, {'key': 'value'});
    });

    test('creates response from JSON', () {
      final json = {
        'statusCode': 201,
        'data': {'id': 1, 'name': 'Test'},
      };

      final response = MayrFakeResponse.fromJson(json);

      expect(response.statusCode, 201);
      expect(response.data, {'id': 1, 'name': 'Test'});
    });

    test('creates response from JSON with default statusCode', () {
      final json = {
        'data': {'id': 1},
      };

      final response = MayrFakeResponse.fromJson(json);

      expect(response.statusCode, 200);
      expect(response.data, {'id': 1});
    });

    test('converts response to JSON', () {
      const response = MayrFakeResponse(
        statusCode: 204,
        data: null,
      );

      final json = response.toJson();

      expect(json['statusCode'], 204);
      expect(json['data'], null);
    });
  });

  group('MayrFakeApi', () {
    late Dio dio;

    setUp(() {
      dio = Dio();
    });

    test('initializes with required parameters', () async {
      await MayrFakeApi.init(
        basePath: 'assets/api',
        attachTo: dio,
      );

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
            data: {'error': 'Custom not found'},
          );
        },
      );

      expect(dio.interceptors.length, greaterThan(0));
    });
  });

  group('MayrFakeInterceptor', () {
    test('creates interceptor with required parameters', () {
      final interceptor = MayrFakeInterceptor(
        basePath: 'assets/api',
      );

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
            data: {'error': 'Custom error'},
          );
        },
      );

      expect(interceptor.resolveNotFound, isNotNull);
    });
  });
}
