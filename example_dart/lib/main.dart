import 'package:dio/dio.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

void main() async {
  print('🧪 MayrFakeApi Pure Dart Example\n');

  final dio = Dio();

  // Initialize with FileAssetLoader for pure Dart applications
  await MayrFakeApi.init(
    basePath: 'api_mocks',
    attachTo: dio,
    assetLoader: FileAssetLoader(baseDirectory: 'api_mocks'),
    delay: Duration(milliseconds: 500),
  );

  print('Making request to /user/profile...\n');

  try {
    // Make a request - this will load from api_mocks/user/profile/get.json
    final response = await dio.get('https://api.example.com/user/profile');

    print('✓ Success!');
    print('Status: ${response.statusCode}');
    print('Data: ${response.data}');
  } catch (e) {
    print('✗ Error: $e');
  }
}
