## 2.0.0

🎉 **Major Release - V2.0.0**

### 🚀 Breaking Changes
- **Flat JSON Structure**: New dot-notation file naming system (e.g., `user.profile.get.json` instead of `user/profile/get.json`)
  - Simplifies asset management - only need to add `assets/api/` once in `pubspec.yaml`
  - No more multiple directory listings required
  - Backwards compatible with v1.x nested structure for seamless migration
  
- **JSON Structure Update**: Changed from `data` to `body` for clarity
  - `body` represents the actual HTTP response body
  - `statusCode` represents the HTTP status code
  - **V1.x Compatibility**: Files using `data` are still supported for backward compatibility

### ✨ New Features
- **Debug Mode**: Added `debug` parameter to `MayrFakeApi.init()` for console logging
  - Logs request interception, file loading attempts, and response status
  - Helps developers debug API simulation issues
  - Example: `await MayrFakeApi.init(debug: true, ...)`

- **Headers and Cookies Support**: Added optional `headers` and `cookies` fields to JSON responses
  - Simulate response headers (e.g., `Content-Type`, custom headers)
  - Simulate response cookies (e.g., `session_id`, `refresh_token`)
  - Both fields are optional and can be omitted if not needed
  
### 🏢 Organizational Changes
- Repository transferred to **MayR-Labs** organization
- Updated LICENSE to reflect MayR Labs (https://mayrlabs.com)
- Added company motto: "Building the future, one line at a time..."
- Updated all URLs to `https://github.com/MayR-Labs/mayr_flutter_fake_api`

### 📦 Migration Guide from v1.x to v2.0

**Option 1: Use Flat Structure (Recommended)**
1. Convert your nested JSON files to flat structure:
   - `assets/api/user/profile/get.json` → `assets/api/user.profile.get.json`
   - `assets/api/products/details/get.json` → `assets/api/products.details.get.json`
   - `assets/api/user/-/profile/get.json` → `assets/api/user.-.profile.get.json`

2. Update JSON structure from `data` to `body`:
   ```json
   {
     "statusCode": 200,
     "body": { ... },
     "headers": { ... },  // Optional
     "cookies": { ... }   // Optional
   }
   ```

3. Update your `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/api/  # Just one line!
   ```

**Option 2: Keep Nested Structure**
- No changes required! V2.0 maintains full backwards compatibility with v1.x nested structure
- Files using `data` instead of `body` continue to work
- The package automatically tries flat structure first, then falls back to nested structure

### 🔧 Technical Changes
- Added flat file resolution with wildcard support
- Enhanced interceptor with debug logging throughout request lifecycle
- Improved error messages and debugging capabilities

---

## 1.0.0

- 🎉 Initial stable release
- ✨ Intercepts Dio HTTP requests and returns fake JSON responses from local assets
- 📁 Supports flexible directory structure for organizing fake API responses
- 🔄 Supports all HTTP methods (GET, POST, PUT, DELETE, etc.)
- 🌟 Dynamic path support with wildcards (e.g., `/user/-/profile`)
- 🔧 Placeholder replacement in JSON responses (`$1`, `$2`, `$timestamp`)
- 🎲 Built-in placeholder support: `$uuid` and `$ulid`
- 🔧 Custom placeholder functionality for user-defined dynamic values
- 📭 Automatic 204 No Content response for empty JSON files
- ⚠️ Error simulation with `error.json` files
- 🚫 Customizable 404 not found responses
- ⏱️ Configurable network delay simulation
- 🎛️ Enable/disable toggle for development/production
- 📚 Comprehensive documentation and examples
- ✅ Full test coverage
- 🐛 Fixed test suite bugs (corrected URL paths and data access patterns)
- 📦 Added `uuid` and `faker` package dependencies

## 0.0.1

- Initial release
