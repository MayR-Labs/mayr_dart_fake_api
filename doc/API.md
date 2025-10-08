# API Documentation

## MayrFakeApi

Main class for initializing and configuring the fake API.

### Static Methods

#### `init()`

Initializes the fake API and attaches it to a Dio instance.

```dart
static Future<void> init({
  required String basePath,
  required Dio attachTo,
  Duration delay = const Duration(milliseconds: 500),
  bool enabled = true,
  MayrFakeResponse Function(String path, String method)? resolveNotFound,
})
```

**Parameters:**

- `basePath` (required): Base path for fake API assets (e.g., 'assets/api')
- `attachTo` (required): Dio instance to attach the interceptor to
- `delay`: Delay to simulate network latency (default: 500ms)
- `enabled`: Whether the fake API is enabled (default: true)
- `resolveNotFound`: Custom resolver for not found endpoints

**Example:**

```dart
await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  delay: Duration(milliseconds: 500),
  enabled: kDebugMode,
);
```

#### `resolveNotFound()`

Sets a custom resolver for not found endpoints.

```dart
static void resolveNotFound(
  MayrFakeResponse Function(String path, String method) resolver,
)
```

**Example:**

```dart
MayrFakeApi.resolveNotFound((path, method) {
  return MayrFakeResponse(
    statusCode: 404,
    data: {'error': 'Not found: $method $path'},
  );
});
```

#### `disable()`

Disables the fake API.

```dart
static void disable()
```

#### `enable()`

Enables the fake API.

```dart
static void enable()
```

---

## MayrFakeResponse

Represents a fake API response.

### Constructor

```dart
const MayrFakeResponse({
  required int statusCode,
  dynamic data,
})
```

**Parameters:**

- `statusCode` (required): HTTP status code
- `data`: Response data (any type)

### Factory Constructors

#### `fromJson()`

Creates a response from JSON.

```dart
factory MayrFakeResponse.fromJson(Map<String, dynamic> json)
```

**Example:**

```dart
final response = MayrFakeResponse.fromJson({
  'statusCode': 200,
  'data': {'id': 1, 'name': 'John'},
});
```

### Methods

#### `toJson()`

Converts response to JSON.

```dart
Map<String, dynamic> toJson()
```

---

## MayrFakeInterceptor

Interceptor for Dio that intercepts requests and returns fake responses.

### Constructor

```dart
MayrFakeInterceptor({
  required String basePath,
  Duration delay = const Duration(milliseconds: 500),
  bool enabled = true,
  MayrFakeResponse Function(String path, String method)? resolveNotFound,
})
```

**Note:** This class is typically not used directly. Use `MayrFakeApi.init()` instead.

---

## File Structure

### Directory Layout

Fake API responses are organized in a directory structure that mirrors your API endpoints:

```
assets/
  api/
    user/
      profile/
        get.json      # GET /api/user/profile
        post.json     # POST /api/user/profile
        put.json      # PUT /api/user/profile
        delete.json   # DELETE /api/user/profile
        error.json    # Error simulation
```

### JSON File Format

Each JSON file should have this structure:

```json
{
  "statusCode": 200,
  "data": {
    // Your response data here
  }
}
```

**Fields:**

- `statusCode` (optional, default: 200): HTTP status code
- `data`: Response data (can be any JSON structure)

### Dynamic Paths (Wildcards)

Use `-` as a wildcard in the directory structure:

```
assets/
  api/
    user/
      -/              # Wildcard for any user ID
        profile/
          get.json
```

This matches requests like:
- `/api/user/123/profile`
- `/api/user/456/profile`
- `/api/user/abc/profile`

### Placeholder Replacement

Inside your JSON files, you can use placeholders:

```json
{
  "statusCode": 200,
  "data": {
    "userId": "$1",
    "name": "User $1",
    "timestamp": "$timestamp",
    "secondId": "$2"
  }
}
```

**Available Placeholders:**

- `$1`, `$2`, `$3`, etc.: Replaced with wildcard values in order
- `$timestamp`: Replaced with current ISO 8601 timestamp

### Empty Files

If a JSON file is empty, it automatically returns a 204 No Content response:

```json
# empty/get.json
(empty file)
```

Returns:
```json
{
  "statusCode": 204
}
```

### Error Simulation

Create an `error.json` file to simulate errors:

```json
{
  "statusCode": 500,
  "data": {
    "code": 500,
    "message": "Internal server error"
  }
}
```

**Note:** The error file is only used if `statusCode >= 400`.

---

## Best Practices

### 1. Use with Debug Mode

Enable the fake API only in debug mode:

```dart
await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  enabled: kDebugMode,
);
```

### 2. Organize by Feature

Structure your fake API files by feature:

```
assets/api/
  auth/
    login/post.json
    logout/post.json
  user/
    profile/get.json
  products/
    list/get.json
```

### 3. Use Realistic Data

Make your fake responses as realistic as possible to catch issues early:

```json
{
  "statusCode": 200,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "avatar": "https://i.pravatar.cc/150",
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

### 4. Test Different Scenarios

Create multiple files to test different scenarios:

```
assets/api/user/profile/
  get.json           # Success case
  error.json         # Error case
  get-empty.json     # Empty response
```

### 5. Version Control

Commit your fake API files to version control so the whole team can use them.

---

## Troubleshooting

### Issue: File not found errors

**Solution:** Ensure your `pubspec.yaml` includes the assets:

```yaml
flutter:
  assets:
    - assets/api/
    - assets/api/user/
    - assets/api/user/profile/
```

### Issue: Interceptor not working

**Solution:** Make sure you initialize before making requests:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dio = Dio();
  await MayrFakeApi.init(
    basePath: 'assets/api',
    attachTo: dio,
  );
  
  runApp(MyApp());
}
```

### Issue: Wrong response returned

**Solution:** Check that:
1. The HTTP method matches the filename (e.g., `get.json` for GET requests)
2. The path structure matches your request URL
3. The `statusCode` field is present in the JSON

### Issue: Placeholder not replaced

**Solution:** Ensure:
1. You're using the wildcard (`-`) in the directory structure
2. The placeholder syntax is correct (`$1`, not `{1}` or `%1`)
3. The request path has the expected number of segments

---

## Migration Guide

### From Manual Mocking

If you're currently using manual mocking:

**Before:**
```dart
class MockApiService {
  Future<User> getUser() async {
    await Future.delayed(Duration(milliseconds: 500));
    return User(id: 1, name: 'John');
  }
}
```

**After:**
```dart
// Just create assets/api/user/get.json:
{
  "statusCode": 200,
  "data": {
    "id": 1,
    "name": "John"
  }
}

// And use real Dio calls:
final response = await dio.get('/api/user');
```

### From json-server

If you're using json-server or similar tools:

1. Convert your JSON files to the mayr_fake_api format (add `statusCode` field)
2. Move files to the appropriate directory structure
3. Replace your json-server URL with fake API initialization

---

## Advanced Usage

### Multiple Interceptors

You can use mayr_fake_api alongside other Dio interceptors:

```dart
dio.interceptors.addAll([
  LogInterceptor(),
  AuthInterceptor(),
  // MayrFakeApi is added via init()
]);
```

### Conditional Enabling

Enable fake API based on environment:

```dart
const useFakeApi = bool.fromEnvironment('USE_FAKE_API', defaultValue: false);

await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  enabled: kDebugMode || useFakeApi,
);
```

### Custom Delay Per Endpoint

While the package doesn't support per-endpoint delays directly, you can chain interceptors:

```dart
class CustomDelayInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path.contains('slow')) {
      await Future.delayed(Duration(seconds: 3));
    }
    handler.next(options);
  }
}

dio.interceptors.add(CustomDelayInterceptor());
await MayrFakeApi.init(...);
```

---

## Examples

See the [example](../example) directory for a complete working example.
