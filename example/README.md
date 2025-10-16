# MayrFakeApi Example

This example demonstrates the use of the `mayr_fake_api` package with Flutter.

## Running the Flutter Example

1. Make sure you have Flutter installed
2. Navigate to the example directory:
   ```bash
   cd example
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Pure Dart Usage

While this example is a Flutter app, `mayr_fake_api` also works with pure Dart applications. For pure Dart usage:

```dart
import 'package:dio/dio.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

void main() async {
  final dio = Dio();

  await MayrFakeApi.init(
    basePath: 'test/assets/api',  // Filesystem path
    attachTo: dio,
    delay: Duration(milliseconds: 500),
    debug: true,
    // assetLoader defaults to DartAssetLoader() for pure Dart
  );

  final response = await dio.get('https://example.com/api/user/profile');
  print(response.data);
}
```

## What This Example Demonstrates

This example app demonstrates the following features of `mayr_fake_api`:

### 1. Basic GET Requests
- **GET User Profile** - Loads `assets/api/user/profile/get.json`
- **GET Products** - Loads `assets/api/products/get.json`
- **GET Product Details** - Loads `assets/api/products/details/get.json`

### 2. POST Requests
- **POST User Profile** - Loads `assets/api/user/profile/post.json`

### 3. Dynamic Routes with Wildcards
- **GET Dynamic User (123)** - Makes a request to `/api/user/123/profile`
  - Matches the wildcard pattern at `assets/api/user/-/profile/get.json`
  - Replaces `$1` placeholder with the actual ID (123)
  - Replaces `$timestamp` with current ISO timestamp

### 4. Empty File Handling
- **GET Empty File** - Loads an empty JSON file
  - Returns a 204 No Content response automatically

### 5. 404 Handling
- **GET Not Found** - Requests a non-existent endpoint
  - Triggers the custom `resolveNotFound` handler
  - Returns a custom 404 response

## Sample Assets Structure

```
example/
  assets/
    api/
      user/
        profile/
          get.json        # Static user profile
          post.json       # Profile update response
          error.json      # Error simulation
        -/                # Wildcard for dynamic user IDs
          profile/
            get.json      # Dynamic user profile with placeholders
      products/
        get.json          # Product list
        details/
          get.json        # Product details
      empty/
        get.json          # Empty file (returns 204)
```

## Custom Features Used

The example demonstrates:

- **Custom delay**: 500ms to simulate network latency
- **Enabled flag**: Set to `kDebugMode` so it only works in debug mode
- **Custom not found resolver**: Provides friendly error messages for missing endpoints

## Modifying the Example

Feel free to:

1. Add more JSON files in the `assets/api` directory
2. Modify existing JSON responses
3. Change the delay duration
4. Add more buttons to test different endpoints
5. Experiment with different HTTP methods (PUT, DELETE, PATCH, etc.)

## Notes

- The fake API only works when enabled (default: `kDebugMode`)
- All requests are intercepted before they reach the network
- No actual network requests are made
- Perfect for offline development and testing
