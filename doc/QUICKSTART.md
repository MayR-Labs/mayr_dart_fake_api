# Quick Start Guide

Get up and running with `mayr_fake_api` in just a few minutes!

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  mayr_fake_api: ^2.0.0
  dio: ^5.0.0  # Required dependency
```

Then run:

```bash
flutter pub get
```

## Basic Setup

### Step 1: Create Your Fake API Files

**V2.0 - Flat Structure (Recommended):**

Create flat structure files using dot notation:

```
your_project/
  assets/
    api/
      user.profile.get.json
```

Create `assets/api/user.profile.get.json`:

```json
{
  "statusCode": 200,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com"
  }
}
```

**V1.x - Nested Structure (Still Supported):**

```
your_project/
  assets/
    api/
      user/
        profile/
          get.json
```

### Step 2: Register Assets in pubspec.yaml

**V2.0 - Much Simpler!** Add just one directory:

```yaml
flutter:
  assets:
    - assets/api/
```

**V1.x - Multiple Directories:**

```yaml
flutter:
  assets:
    - assets/api/
    - assets/api/user/
    - assets/api/user/profile/
```

### Step 3: Initialize in Your App

In your `main.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create Dio instance
  final dio = Dio();

  // Initialize fake API
  await MayrFakeApi.init(
    basePath: 'assets/api',
    attachTo: dio,
    delay: Duration(milliseconds: 500),
    enabled: kDebugMode,  // Only in debug mode
    debug: true,  // Enable debug logging (v2.0+)
  );

  runApp(MyApp(dio: dio));
}
```

### Step 4: Make Requests

Use Dio as you normally would:

```dart
class MyHomePage extends StatelessWidget {
  final Dio dio;

  const MyHomePage({required this.dio});

  Future<void> loadUserProfile() async {
    try {
      final response = await dio.get('https://api.example.com/api/user/profile');
      print('User: ${response.data}');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(
        child: ElevatedButton(
          onPressed: loadUserProfile,
          child: Text('Load Profile'),
        ),
      ),
    );
  }
}
```

That's it! The request to `https://api.example.com/api/user/profile` will be intercepted and return the data from `assets/api/user/profile/get.json`.

## Common Scenarios

### Different HTTP Methods

**V2.0 - Flat Files:**

```
assets/api/user.profile.get.json      # GET requests
assets/api/user.profile.post.json     # POST requests
assets/api/user.profile.put.json      # PUT requests
assets/api/user.profile.delete.json   # DELETE requests
```

**V1.x - Nested Files:**

```
assets/api/user/profile/
  get.json      # GET requests
  post.json     # POST requests
  put.json      # PUT requests
  delete.json   # DELETE requests
```

Example `post.json`:

```json
{
  "statusCode": 201,
  "data": {
    "message": "Profile updated successfully"
  }
}
```

### Dynamic Routes

Use `-` as a wildcard in your path:

**V2.0 - Flat Structure:**
```
assets/api/user.-.profile.get.json
```

**V1.x - Nested Structure:**
```
assets/api/user/-/profile/get.json
```

This will match:
- `/api/user/123/profile`
- `/api/user/456/profile`
- `/api/user/abc/profile`

And you can use the wildcard value in your JSON:

```json
{
  "statusCode": 200,
  "data": {
    "userId": "$1",
    "name": "User $1"
  }
}
```

### Error Simulation

Create an `error.json` file:

```json
{
  "statusCode": 500,
  "data": {
    "message": "Server error occurred"
  }
}
```

### Empty Responses

Create an empty file for 204 No Content responses:

```bash
touch assets/api/user/logout/post.json
```

## Configuration Options

### Custom Delay

Simulate slower network:

```dart
await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  delay: Duration(seconds: 2),  // 2 second delay
);
```

### Enable/Disable

Control when the fake API is active:

```dart
await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  enabled: kDebugMode,  // Only in debug mode
);
```

Or manually:

```dart
MayrFakeApi.disable();  // Disable
MayrFakeApi.enable();   // Enable
```

### Custom 404 Handler

Provide custom responses for missing endpoints:

```dart
await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  resolveNotFound: (path, method) {
    return MayrFakeResponse(
      statusCode: 404,
      data: {
        'error': 'Endpoint not found',
        'path': path,
        'method': method,
      },
    );
  },
);
```

## Tips

1. **Start Simple**: Begin with a few static endpoints and expand as needed
2. **Use Debug Mode**: Set `enabled: kDebugMode` to automatically disable in production
3. **Organize by Feature**: Group related endpoints together in your directory structure
4. **Realistic Data**: Use realistic data to catch issues early in development
5. **Version Control**: Commit your fake API files so the team can use them

## Next Steps

- Read the [API Documentation](API.md) for detailed information
- Check out the [example app](../example) for a complete working example
- Learn about [advanced features](API.md#advanced-usage) like wildcards and placeholders

## Troubleshooting

**Problem**: Getting file not found errors

**Solution**: 
- V2.0: Check that your flat files use dot notation (e.g., `user.profile.get.json`)
- V1.x: Make sure your nested assets are properly registered in `pubspec.yaml`
- Ensure the file exists in the correct location

---

**Problem**: Requests are going to the real network

**Solution**: Verify that:
1. `MayrFakeApi.init()` is called before any requests
2. The `enabled` parameter is `true`
3. Your paths match between the request and the file structure

---

**Problem**: Wrong response being returned

**Solution**: Check that:
1. The HTTP method matches (GET → `user.profile.get.json` for v2.0 or `get.json` for v1.x)
2. The path structure is correct (use dots for v2.0 or slashes for v1.x)
3. The JSON file has proper format with `statusCode` and `data`

---

For more help, see the full [API Documentation](API.md) or check the [issues on GitHub](https://github.com/MayR-Labs/mayr_flutter_fake_api/issues).
