![License](https://img.shields.io/badge/license-MIT-blue.svg?label=Licence)
![Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)

![Pub Version](https://img.shields.io/pub/v/mayr_fake_api?style=plastic&label=Version)
![Pub.dev Score](https://img.shields.io/pub/points/mayr_fake_api?label=Score&style=plastic)
![Pub Likes](https://img.shields.io/pub/likes/mayr_fake_api?label=Likes&style=plastic)
![Pub.dev Publisher](https://img.shields.io/pub/publisher/mayr_fake_api?label=Publisher&style=plastic)
![Downloads](https://img.shields.io/pub/dm/mayr_fake_api.svg?label=Downloads&style=plastic)

![Build Status](https://img.shields.io/github/actions/workflow/status/MayR-Labs/mayr_flutter_fake_api/ci.yaml?label=Build)
![Issues](https://img.shields.io/github/issues/MayR-Labs/mayr_flutter_fake_api.svg?label=Issues)
![Last Commit](https://img.shields.io/github/last-commit/MayR-Labs/mayr_flutter_fake_api.svg?label=Latest%20Commit)
![Contributors](https://img.shields.io/github/contributors/MayR-Labs/mayr_flutter_fake_api.svg?label=Contributors)


# 🧪 mayr_fake_api

No internet? No backend? No problem.

A lightweight fake API simulator for Flutter and Dart apps — perfect for local development, prototyping, and offline testing.

With **mayr_fake_api**, you can simulate real REST API calls using simple JSON files — no server required.

---

## 🚀 Overview

`mayr_fake_api` intercepts network requests (e.g. from **Dio** or **http**) and serves data from local JSON files in your Flutter app’s `assets/` directory.

It’s designed to make your development flow **smoother**, **faster**, and **independent** of backend delays.

---

## 🚀 Features

* 💾 Use local JSON files to simulate REST endpoints.
* 🧭 Supports folder-structured routing (e.g. `/api/user/profile.json`).
* ⚡ Supports multiple HTTP methods (`GET`, `POST`, `PUT`, `DELETE`, etc.) using method-specific JSON naming.
* ❌ Built-in 404 simulation with customizable resolver.
* 🪄 Dynamic data support with wildcards and placeholders.
* 🎲 **50+ built-in placeholders** powered by Faker: UUIDs, user data, addresses, dates, random values, and more.
* 🎯 **Parameterized placeholders**: `$randomInt(min,max)`, `$choose(a,b,c)`, `$image(width,height)`.
* 🔧 **Custom placeholders**: Define your own dynamic value generators.
* 🌐 **Request context**: Access `$method`, `$path`, `$query` in your responses.
* 🧱 Lightweight — no dependencies on backend servers.
* 🧍 Ideal for demos, offline-first apps, and rapid prototyping.
* ⚙️ Enable or disable fake mode at runtime
* 🧠 Simulate network delays

---

## 🛠️ Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  mayr_fake_api: ^2.0.0
```

Then import it:

```dart
import 'package:mayr_fake_api/mayr_fake_api.dart';
```

**Migrating from v1.x?** See the [Migration Guide](MIGRATION.md) for a smooth transition.

---

## 🧩 Directory Structure

**New in v2.0.0:** Flat JSON structure for simplified asset management!

Instead of nested directories, use a flat structure with dot notation:

```
assets/
  api/
    user.profile.get.json
    user.profile.post.json
    user.profile.put.json
    user.profile.delete.json
    user.profile.error.json
    products.get.json
    products.details.get.json
```

This means you only need to add **one directory** to your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/api/
```

**Backward compatibility:** The package still supports the v1.x nested directory structure for seamless migration.

Each JSON file corresponds to a simulated endpoint.

**V2.0 JSON Structure:**

The JSON files should contain `statusCode` (the HTTP status code) and `body` (the actual response body):

```json
{
    "statusCode": 200,
    "body": {
        // ... Your response data here
    },
    "headers": {
        // Optional: Response headers
        "Content-Type": "application/json",
        "X-Custom-Header": "value"
    },
    "cookies": {
        // Optional: Response cookies
        "session_id": "abc123",
        "user_token": "xyz789"
    }
}
```

**Note:** The `headers` and `cookies` fields are optional. If not provided, only the status code and body will be returned.

**V1.x Compatibility:** Files using `data` instead of `body` are still supported for backward compatibility.

---

## 💡 How It Works

* When you make a **GET** request to `/api/user/profile`,
  the package looks for `api/user.profile.get.json` (v2.0) or `api/user/profile/get.json` (v1.x).

* When you make a **POST** request to `/api/user/profile`,
  it looks for `api/user.profile.post.json` (v2.0) or `api/user/profile/post.json` (v1.x).

* You can use **any folder structure**, e.g.:

  ```
  api/user/profile/get.json
  api/user/profile/update/post.json
  ```

* If the file doesn’t exist, it returns a **404** response by default —
  but you can override that with a **custom not-found resolver**.

---

## 🧱 Example Usage

### 1. Simple setup

```dart

import 'package:dio/dio.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = Dio();

  await MayrFakeApi.init(
    basePath: 'assets/api',
    attachTo: dio,
    delay: Duration(milliseconds: 500),
    enabled: kDebugMode,
    debug: true,  // Enable debug logging (v2.0+)
    // resolveNotFound: ...
    //
  );

  runApp(MyApp());
}
```

### 2. Make a request

```dart
final response = await dio.get('https://example.com/api/user/profile');
```

This will attempt to load `api/user.profile.get.json` (v2.0) or fall back to `api/user/profile/get.json` (v1.x).

---

## 🧩 Handling 404 Responses

If a requested JSON file doesn’t exist, a **404** is returned automatically.

You can customize what happens using:

```dart
MayrFakeApi.resolveNotFound((path, method) {
  return MayrFakeResponse(
    statusCode: 404,
    data: {'error': 'No fake endpoint found for $method $path'},
  );
});
```

---

## 🚨 Simulating Errors

To simulate API errors, create an `error.json` file in any directory.
The error file can contain:

```json
{
  "statusCode": 500,
  "data": {
      "code": 500,
      "message": "Internal server error",
      "details": "Something went wrong"
  }
}
```

When the API detects this file, it throws a fake error response automatically.

If the `statusCode` is missing or set to `200`, the error file is ignored

---

## ⚙️ Dynamic Data

Excellent — that’s a **smart and elegant** convention 👏
Using a reserved folder (like `-`) to signal **dynamic data routes** keeps things clean and file-based while still flexible.

Here’s the rewritten **Dynamic Data** section for your `mayr_fake_api` README, following your `api/user/-/profile/get.json` pattern 👇

---

## ⚙️ Dynamic Data

Dynamic routes let you simulate responses that change depending on runtime input — for example, when you want user-specific data, random IDs, or timestamps — all while keeping your API file-based.

To define a **dynamic endpoint**, include a `-` segment in your path.
For example:

```
api/
  user/
    -/
      profile/
        get.json
```

The `-` folder acts as a **dynamic wildcard** that can represent **any runtime value**.

---

### Example Usage

If you make a request like:

```dart
final response = await dio.get('https://example.com/api/user/123/profile');
```

The package will automatically match and resolve:

**V2.0:** `api/user.-.profile.get.json`  
**V1.x:** `api/user/-/profile/get.json`

---

### Dynamic Placeholder Replacement

Inside your dynamic JSON files, you can reference wildcard values and use built-in placeholders for realistic mock data:

```json
{
  "statusCode": 200,
  "data": {
    "id": "$uuid",
    "userId": "$1",
    "name": "$userFullName",
    "email": "$userEmail",
    "createdAt": "$timestamp"
  }
}
```

#### Built-in Placeholders

**Request Context:**
- `$method` - HTTP method (GET, POST, etc.)
- `$path` - Full request path
- `$query` - Query parameters

**Unique Identifiers:**
- `$uuid` - UUID v4 (e.g., `550e8400-e29b-41d4-a716-446655440000`)
- `$ulid` - ULID - Lexicographically sortable (e.g., `01HQZXVZQM7K9Q0W0R0W0R0W0R`)
- `$id` - Random numeric ID (0-999999)
- `$shortId` - Short alphanumeric ID (8 characters)
- `$hash` - 40-character hexadecimal hash

**Date & Time:**
- `$timestamp` - ISO 8601 timestamp (e.g., `2025-01-15T10:30:45.123Z`)
- `$datetime` - Same as $timestamp
- `$now` - Same as $timestamp
- `$date` - Current date (YYYY-MM-DD)
- `$time` - Current time (HH:MM:SS)

**User Data (via Faker):**
- `$userId` - Random UUID for user ID
- `$userEmail` - Random email address
- `$username` - Random username
- `$userFirstName` - Random first name
- `$userLastName` - Random last name
- `$userFullName` - Random full name
- `$userAvatar` - Avatar image URL
- `$userPhone` - Random phone number
- `$userToken` - Random 64-character token

**Location Data (via Faker):**
- `$country` - Country name
- `$countryCode` - Country code
- `$city` - City name
- `$state` - State name
- `$address` - Street address
- `$timezone` - Timezone
- `$ipAddress` - Random IP address

**Business Data (via Faker):**
- `$currency` - Currency code (e.g., USD)
- `$jobTitle` - Job title
- `$companyName` - Company name
- `$productName` - Product name
- `$sku` - Product SKU

**Random Data (via Faker):**
- `$randomSentence` - Random lorem ipsum sentence
- `$randomWord` - Random word
- `$randomBool` - Random boolean (true/false)

**Design/Visual:**
- `$hexColor` - Hex color code (e.g., #FF5733)
- `$color` - Color name
- `$image(width,height)` - Placeholder image URL (e.g., `$image(300,200)`)

**Other:**
- `$version` - Random semantic version (e.g., 1.2.3)
- `$statusCode` - HTTP status code (default: 200)

**Parameterized Placeholders:**
- `$randomInt(min,max)` - Random integer in range (e.g., `$randomInt(1,100)`)
- `$randomFloat(min,max)` - Random float in range (e.g., `$randomFloat(0,1)`)
- `$choose(a,b,c)` - Randomly picks one option (e.g., `$choose(red,green,blue)`)

**Wildcard Values:**
- `$1`, `$2`, `$3`, etc. - Replaced with wildcard values from URL path

#### Custom Placeholders

You can also define **custom placeholders**:

```dart
await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  customPlaceholders: {
    'sessionId': () => 'session-${DateTime.now().millisecondsSinceEpoch}',
    'apiVersion': () => 'v2.0',
    'environment': () => kDebugMode ? 'dev' : 'prod',
  },
);
```

Then in your JSON:

```json
{
  "statusCode": 200,
  "data": {
    "sessionId": "$sessionId",
    "apiVersion": "$apiVersion",
    "environment": "$environment"
  }
}
```

#### Example Usage

```json
{
  "statusCode": 200,
  "data": {
    "user": {
      "id": "$uuid",
      "name": "$userFullName",
      "email": "$userEmail",
      "avatar": "$userAvatar",
      "phone": "$userPhone",
      "address": {
        "street": "$address",
        "city": "$city",
        "state": "$state",
        "country": "$country",
        "zip": "$randomInt(10000,99999)"
      }
    },
    "metadata": {
      "timestamp": "$timestamp",
      "version": "$version",
      "statusCode": "$statusCode",
      "requestId": "$shortId"
    }
  }
}
```

---

### Example in Action

**V2.0 Flat Structure:**
```
api/user.-.profile.get.json
```

**V1.x Nested Structure:**
```
api/
  user/
    -/
      profile/
        get.json
```

and `get.json` containing:

```json
{
  "statusCode": 200,
  "data": {
    "userId": "$1",
    "name": "User $1",
    "timestamp": "$timestamp"
  }
}
```

A request like:

```dart
final res = await api.request('/user/42/profile', method: 'GET');
print(res.data);
```

will output something like:

```json
{
  "statusCode": 200,
  "data": {
    "id": "42",
    "name": "User #42",
    "fetched_at": "2025-10-06T12:34:56.789Z"
  }
}
```

---

### Notes

* You can include **multiple wildcards**, e.g. `user.-.posts.-.get.json` (v2.0) or `/api/user/-/posts/-/get.json` (v1.x).
  Placeholders `$1`, `$2`, `$3`, etc. will be replaced accordingly.
* If no placeholder is found, the file is returned as-is.
* Works seamlessly with all HTTP methods (`GET`, `POST`, etc.).
* **50+ built-in placeholders** available for realistic mock data (powered by Faker)
* Supports **parameterized placeholders** for dynamic ranges and choices
* Custom placeholders can be defined during initialization to generate dynamic values
* All placeholders are evaluated fresh on each request for realistic data

---

## 🪶 Empty JSON Files

If a JSON file exists but is **empty**,
the API returns a **204 No Content** response automatically.

---

## 🔌 Example Directory Recap

**V2.0 Flat Structure (Recommended):**
```
api/
  user.profile.get.json              -> returns profile data
  user.profile.post.json             -> simulate POST update
  user.profile.error.json            -> simulate error
  products.get.json                  -> product listing
  products.details.get.json          -> single product details
  user.-.profile.get.json            -> dynamic user profile
```

**V1.x Nested Structure (Still Supported):**
```
api/
  user/
    profile/
      get.json             -> returns profile data
      post.json            -> simulate POST update
      error.json           -> simulate error
  products/
    get.json               -> product listing
    details/get.json       -> single product details
```

---

## 🧪 Example Usage

```dart
void main() async {
   WidgetsFlutterBinding.ensureInitialized();

  final dio = Dio(
    // ... DIO setup here
  );

  await MayrFakeApi.init(
    basePath: 'assets/api',
    attachTo: dio,
    delay: Duration(milliseconds: 500),
    debug: true,  // Enable debug logging (v2.0+)
  );

  // rest of code
}

void elsewhere() async {
    final response = await dio.get('api/user');
}
```

---

## 📢 Additional Information

### 🤝 Contributing
Contributions are highly welcome!
If you have ideas for new extensions, improvements, or fixes, feel free to fork the repository and submit a pull request.

Please make sure to:
- Follow the existing coding style.
- Write tests for new features.
- Update documentation if necessary.

> Let's build something amazing together!

---

### 🐛 Reporting Issues
If you encounter a bug, unexpected behaviour, or have feature requests:
- Open an issue on the repository.
- Provide a clear description and steps to reproduce (if it's a bug).
- Suggest improvements if you have any ideas.

> Your feedback helps make the package better for everyone!

---

### 🧑‍💻 Author

**MayR Labs**

Building the future, one line at a time...

Crafting clean, reliable, and human-centric Flutter and Dart solutions.
🌍 [mayrlabs.com](https://mayrlabs.com)

---

### 📜 Licence
This package is licensed under the MIT License — which means you are free to use it for commercial and non-commercial projects, with proper attribution.

> See the [LICENSE](LICENSE) file for more details.

MIT © 2025 [MayR Labs](https://github.com/mayrlabs)

---

## 🌟 Support

If you find this package helpful, please consider giving it a ⭐️ on GitHub — it motivates and helps the project grow!

You can also support by:
- Sharing the package with your friends, colleagues, and tech communities.
- Using it in your projects and giving feedback.
- Contributing new ideas, features, or improvements.

> Every little bit of support counts! 🚀💙
