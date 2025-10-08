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
