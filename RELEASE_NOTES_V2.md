# V2.0.0 Release Summary

## Overview
Version 2.0.0 of `mayr_fake_api` introduces significant improvements to asset management and debugging capabilities while maintaining full backward compatibility with v1.x.

## Key Features

### 1. Flat JSON Structure
**The Problem:** V1.x required multiple directories to be listed in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/api/
    - assets/api/user/
    - assets/api/user/profile/
    - assets/api/products/
    - assets/api/products/details/
```

**The Solution:** V2.0 uses flat file structure with dot notation:
```yaml
flutter:
  assets:
    - assets/api/  # That's it!
```

Files are named using dots instead of nested directories:
- `user/profile/get.json` → `user.profile.get.json`
- `products/details/get.json` → `products.details.get.json`
- `user/-/profile/get.json` → `user.-.profile.get.json`

### 2. JSON Structure Update (data → body)

**The Change:** Renamed `data` field to `body` for better clarity:

**V1.x Format:**
```json
{
  "statusCode": 200,
  "data": { ... }
}
```

**V2.0 Format:**
```json
{
  "statusCode": 200,
  "body": { ... },
  "headers": { ... },  // Optional
  "cookies": { ... }   // Optional
}
```

**Rationale:**
- `statusCode` = HTTP status code (e.g., 200, 404, 500)
- `body` = actual HTTP response body (the data)
- `headers` = optional response headers
- `cookies` = optional response cookies

**Backward Compatibility:** Files using `data` still work via legacy getter.

### 3. Headers and Cookies Support

New optional fields in JSON responses:

```json
{
  "statusCode": 200,
  "body": {
    "message": "Login successful",
    "user": { ... }
  },
  "headers": {
    "Content-Type": "application/json",
    "X-Auth-Token": "Bearer abc123"
  },
  "cookies": {
    "session_id": "sess_abc123",
    "refresh_token": "refresh_xyz789"
  }
}
```

Both fields are optional and can be omitted if not needed.

### 4. Debug Mode
New `debug` parameter enables console logging to help troubleshoot issues:

```dart
await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  debug: true,  // Enable debug logging
);
```

Debug output shows:
- Request interception
- File path attempts (flat and nested)
- Which file was loaded
- Response status codes
- Error conditions

Example output:
```
[MayrFakeApi] Intercepting request: GET https://example.com/api/user/profile
[MayrFakeApi] Request path: api/user/profile
[MayrFakeApi] HTTP method: get
[MayrFakeApi] Trying flat structure: assets/api/api.user.profile.get.json
[MayrFakeApi] Loaded from flat structure: assets/api/user.profile.get.json
[MayrFakeApi] Found response with status code: 200
[MayrFakeApi] Returning successful response
```

### 5. Organizational Changes
- Repository transferred to **MayR-Labs** organization
- All URLs updated to `https://github.com/MayR-Labs/mayr_flutter_fake_api`
- LICENSE updated to reflect MayR Labs (https://mayrlabs.com)
- Version bumped to 2.0.0

## Technical Implementation

### File Resolution Strategy
The interceptor now follows this priority:
1. **Try flat structure** (v2.0 format)
   - `assets/api/user.profile.get.json`
2. **Try flat structure with wildcards**
   - `assets/api/user.-.profile.get.json`
3. **Try flat error file**
   - `assets/api/user.profile.error.json`
4. **Fallback to nested structure** (v1.x format)
   - `assets/api/user/profile/get.json`
5. **Try nested with wildcards**
   - `assets/api/user/-/profile/get.json`
6. **Try nested error file**
   - `assets/api/user/profile/error.json`
7. **Return 404** (or custom resolver)

### New Methods
- `_convertToFlatPath()`: Converts path segments to dot notation
- `_tryFlatWithWildcards()`: Recursively tries flat paths with wildcards

### Debug Logging Points
- Request interception start/skip
- Network delay simulation
- Path extraction and method detection
- Each file attempt (flat and nested)
- Successful file loads
- Response type (success/error)
- 404 handling
- Exception handling

## Backward Compatibility

**100% compatible with v1.x!**

Existing code continues to work without any changes. The package automatically:
1. Tries the new flat structure first
2. Falls back to the old nested structure if flat files aren't found
3. Supports both structures simultaneously

This means:
- No breaking changes
- Gradual migration possible
- Can mix both structures during transition

## Migration Path

### Easy Migration (Recommended)
1. Create new flat files alongside existing nested files
2. Test thoroughly
3. Remove nested files when confident
4. Simplify `pubspec.yaml`

### No Migration Required
Keep using nested structure - it still works perfectly!

## Files Changed

### Core Implementation
- `lib/src/mayr_fake_api.dart`: Added `debug` parameter
- `lib/src/mayr_fake_interceptor.dart`: Added flat structure support and debug logging

### Assets
- Created 5 flat test files in `test/assets/api/`
- Created 7 flat example files in `example/assets/api/`
- Kept all nested files for backward compatibility

### Documentation
- `README.md`: Updated with v2.0 examples and MayR-Labs URLs
- `CHANGELOG.md`: Added v2.0.0 release notes
- `QUICKSTART.md`: Updated with flat structure examples
- `MIGRATION.md`: New comprehensive migration guide
- `PROJECT_SUMMARY.md`: Updated for v2.0.0

### Configuration
- `pubspec.yaml`: Version 2.0.0, MayR-Labs URLs, simplified assets
- `example/pubspec.yaml`: Simplified assets to single directory
- `LICENSE`: Updated to MayR Labs

### Tests
- `test/flat_structure_test.dart`: New comprehensive tests for flat structure

## Benefits for Users

1. **Simpler Configuration**: One line in `pubspec.yaml` instead of many
2. **Easier Navigation**: All endpoints visible in one directory listing
3. **Less Maintenance**: No need to update `pubspec.yaml` when adding endpoints
4. **Better Debugging**: Debug mode shows exactly what's happening
5. **Clearer Structure**: File names show complete endpoint paths
6. **Smooth Migration**: Can migrate gradually or not at all

## Statistics

- **21 files changed** in total
- **5 new flat test files** created
- **7 new flat example files** created
- **1 new migration guide** added
- **All documentation** updated
- **Full backward compatibility** maintained
- **Zero breaking changes**

## Conclusion

Version 2.0.0 represents a significant improvement in developer experience while maintaining the reliability and simplicity that made v1.0 successful. The flat structure simplifies setup and maintenance, debug mode improves troubleshooting, and the migration to MayR-Labs ensures continued support and development.

The package is production-ready and fully tested.
