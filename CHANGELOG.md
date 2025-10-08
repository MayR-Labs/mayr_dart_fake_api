## 1.1.0

- 🎲 Added built-in placeholder support: `$uuid` and `$ulid`
- 🔧 Added custom placeholder functionality for user-defined dynamic values
- 🐛 Fixed test suite bugs (corrected URL paths and data access patterns)
- 📚 Enhanced documentation with placeholder usage examples
- ✅ Added comprehensive tests for placeholder features
- 📦 Added `uuid` package dependency for UUID generation

## 1.0.0

- 🎉 Initial stable release
- ✨ Intercepts Dio HTTP requests and returns fake JSON responses from local assets
- 📁 Supports flexible directory structure for organizing fake API responses
- 🔄 Supports all HTTP methods (GET, POST, PUT, DELETE, etc.)
- 🌟 Dynamic path support with wildcards (e.g., `/user/-/profile`)
- 🔧 Placeholder replacement in JSON responses (`$1`, `$2`, `$timestamp`)
- 📭 Automatic 204 No Content response for empty JSON files
- ⚠️ Error simulation with `error.json` files
- 🚫 Customizable 404 not found responses
- ⏱️ Configurable network delay simulation
- 🎛️ Enable/disable toggle for development/production
- 📚 Comprehensive documentation and examples
- ✅ Full test coverage

## 0.0.1

- Initial release
