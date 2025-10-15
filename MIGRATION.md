# Migration Guide: V1.x to V2.0.0

This guide will help you upgrade from `mayr_fake_api` v1.x to v2.0.0.

## What's New in V2.0.0?

### 🎉 Major Features

1. **Flat JSON Structure**: Simplified file organization using dot notation
2. **Debug Mode**: New debugging capability with console logging
3. **MayR-Labs Organization**: Repository moved to official organization

### Breaking Changes

None! V2.0.0 is **fully backward compatible** with v1.x. Your existing nested structure will continue to work.

## Migration Options

### Option 1: Use New Flat Structure (Recommended)

The flat structure is simpler and requires less configuration.

#### Step 1: Convert Your JSON Files

**Before (V1.x - Nested):**
```
assets/
  api/
    user/
      profile/
        get.json
        post.json
    products/
      get.json
      details/
        get.json
    user/
      -/
        profile/
          get.json
```

**After (V2.0 - Flat):**
```
assets/
  api/
    user.profile.get.json
    user.profile.post.json
    products.get.json
    products.details.get.json
    user.-.profile.get.json
```

#### Step 2: Update pubspec.yaml

**Before (V1.x):**
```yaml
flutter:
  assets:
    - assets/api/
    - assets/api/user/
    - assets/api/user/profile/
    - assets/api/user/-/profile/
    - assets/api/products/
    - assets/api/products/details/
```

**After (V2.0):**
```yaml
flutter:
  assets:
    - assets/api/
```

That's it! Just one line! 🎉

#### Step 3: Update JSON Structure (data → body)

**Before (V1.x format):**
```json
{
  "statusCode": 200,
  "data": {
    "id": 1,
    "name": "John"
  }
}
```

**After (V2.0 format):**
```json
{
  "statusCode": 200,
  "body": {
    "id": 1,
    "name": "John"
  },
  "headers": {
    "Content-Type": "application/json"
  },
  "cookies": {
    "session_id": "abc123"
  }
}
```

**Note:** `headers` and `cookies` are optional. V1.x files using `data` still work for backward compatibility.

#### Step 4: (Optional) Enable Debug Mode

Update your initialization code to use the new debug parameter:

```dart
await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  delay: Duration(milliseconds: 500),
  enabled: kDebugMode,
  debug: kDebugMode,  // NEW: Enable debug logging
);
```

### Option 2: Keep Using Nested Structure

If you prefer to keep your existing structure, you don't need to change anything! V2.0.0 automatically falls back to the nested structure if flat files aren't found.

Your v1.x code (including files using `data` instead of `body`) will continue to work without any modifications.

## Conversion Script

Here's a simple bash script to help convert your nested structure to flat structure:

```bash
#!/bin/bash

# Convert nested structure to flat structure
# Usage: ./convert_to_flat.sh assets/api

API_DIR="$1"

if [ -z "$API_DIR" ]; then
  echo "Usage: $0 <api_directory>"
  exit 1
fi

# Find all JSON files and copy them to flat structure
find "$API_DIR" -type f -name "*.json" | while read file; do
  # Get relative path from API_DIR
  rel_path="${file#$API_DIR/}"
  
  # Convert slashes to dots
  flat_name=$(echo "$rel_path" | sed 's/\//./g')
  
  # Copy to new location
  cp "$file" "$API_DIR/$flat_name"
  echo "Created: $API_DIR/$flat_name"
done

echo "Conversion complete!"
echo "You can now remove the nested directories and update your pubspec.yaml"
```

Save this as `convert_to_flat.sh`, make it executable with `chmod +x convert_to_flat.sh`, and run:

```bash
./convert_to_flat.sh assets/api
```

## Testing Your Migration

After migration, test your endpoints:

1. Enable debug mode:
   ```dart
   await MayrFakeApi.init(
     basePath: 'assets/api',
     attachTo: dio,
     debug: true,  // Enable logging
   );
   ```

2. Make a request and check the console output:
   ```dart
   final response = await dio.get('https://example.com/api/user/profile');
   ```

3. Look for debug messages like:
   ```
   [MayrFakeApi] Intercepting request: GET https://example.com/api/user/profile
   [MayrFakeApi] Trying flat structure: assets/api/user.profile.get.json
   [MayrFakeApi] Loaded from flat structure: assets/api/user.profile.get.json
   ```

## Troubleshooting

### Files Not Found

**Symptoms:** Getting 404 errors after migration

**Solution:**
1. Enable debug mode to see which files are being looked up
2. Verify file naming: paths should use dots, not slashes
3. Check that your `pubspec.yaml` includes `assets/api/`
4. Run `flutter clean` and `flutter pub get`

### Placeholders Not Working

**Symptoms:** Seeing literal `$timestamp`, `$uuid` in responses

**Solution:**
- This is a display/parsing issue, not a migration issue
- Check that your JSON files have proper structure with `statusCode` and `data`
- Placeholders are case-sensitive

### Both Structures Present

**Symptoms:** Not sure which structure is being used

**Solution:**
- The package tries flat structure first, then nested
- Enable debug mode to see which file is loaded
- Gradually remove nested files after confirming flat structure works

## Benefits of Flat Structure

1. **Simpler `pubspec.yaml`**: One line instead of many
2. **Easier navigation**: All endpoints visible in one directory
3. **Less maintenance**: No need to update pubspec when adding endpoints
4. **Clearer structure**: File names show full endpoint path

## Need Help?

- Check the [README](../README.md) for updated examples
- See the [Quick Start Guide](doc/QUICKSTART.md) for setup instructions
- Open an issue on [GitHub](https://github.com/MayR-Labs/mayr_flutter_fake_api/issues)

---

**Note:** Remember to commit your changes in small steps when migrating, so you can easily roll back if needed!
