# Pure Dart Example

This example demonstrates how to use `mayr_fake_api` in a pure Dart application (without Flutter).

## Setup

1. Create your API mock files:

```bash
mkdir -p api_mocks/user/profile
```

2. Create `api_mocks/user/profile/get.json`:

```json
{
  "statusCode": 200,
  "data": {
    "id": "$uuid",
    "name": "$userFullName",
    "email": "$userEmail",
    "timestamp": "$timestamp"
  }
}
```

## Usage

```dart
import 'package:dio/dio.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

void main() async {
  final dio = Dio();

  // Initialize with FileAssetLoader for pure Dart
  await MayrFakeApi.init(
    basePath: 'api_mocks',
    attachTo: dio,
    assetLoader: FileAssetLoader(baseDirectory: 'api_mocks'),
    delay: Duration(milliseconds: 500),
  );

  // Make requests as usual
  final response = await dio.get('https://api.example.com/user/profile');
  print('User data: ${response.data}');
}
```

## Running

```bash
dart run lib/main.dart
```

This will load the mock data from your local file system instead of making real network requests.
