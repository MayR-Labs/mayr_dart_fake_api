![License](https://img.shields.io/badge/license-MIT-blue.svg?label=Licence)
![Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)

![Pub Version](https://img.shields.io/pub/v/mayr_fake_api?style=plastic&label=Version)
![Pub.dev Score](https://img.shields.io/pub/points/mayr_fake_api?label=Score&style=plastic)
![Pub Likes](https://img.shields.io/pub/likes/mayr_fake_api?label=Likes&style=plastic)
![Pub.dev Publisher](https://img.shields.io/pub/publisher/mayr_fake_api?label=Publisher&style=plastic)
![Downloads](https://img.shields.io/pub/dm/mayr_fake_api.svg?label=Downloads&style=plastic)

![Build Status](https://img.shields.io/github/actions/workflow/status/YoungMayor/mayr_flutter_fake_api/ci.yaml?label=Build)
![Issues](https://img.shields.io/github/issues/YoungMayor/mayr_flutter_fake_api.svg?label=Issues)
![Last Commit](https://img.shields.io/github/last-commit/YoungMayor/mayr_flutter_fake_api.svg?label=Latest%20Commit)
![Contributors](https://img.shields.io/github/contributors/YoungMayor/mayr_flutter_fake_api.svg?label=Contributors)


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
* 🎲 Built-in placeholders: `$timestamp`, `$uuid`, `$ulid` for dynamic values.
* 🔧 Custom placeholders: Define your own dynamic value generators.
* 🧱 Lightweight — no dependencies on backend servers.
* 🧍 Ideal for demos, offline-first apps, and rapid prototyping.
* ⚙️ Enable or disable fake mode at runtime
* 🧠 Simulate network delays

---

## 🛠️ Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  mayr_fake_api: ^1.0.0
```

Then import it:

```dart
import 'package:mayr_fake_api/mayr_fake_api.dart';
```

---

## 🧩 Directory Structure

By default, your fake API data can live anywhere in your project, but the conventional layout is:

```
assets/
  api/
    user/
      profile/
        get.json
        post.json
        put.json
        delete.json
        error.json
```

Each JSON file corresponds to a simulated endpoint.

And the JSON structures should contain statusCode and data. Example

```json
{
    "statusCode": 201,
    "data": {
        // ... The data here
    }
}
```

---

## 💡 How It Works

* When you make a **GET** request to `/api/user/profile`,
  the package looks for `api/user/profile/get.json`.

* When you make a **POST** request to `/api/user/profile`,
  it looks for `api/user/profile/post.json`.

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

This will attempt to load `api/user/profile/get.json`.

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

```
api/user/-/profile/get.json
```

instead of looking for a literal `/user/123/` path.

---

### Dynamic Placeholder Replacement

Inside your dynamic JSON files, you can also reference the wildcard values using placeholders like:

```json
{
  "statusCode": 200,
  "data": {
    "userId": "$1",
    "name": "Dynamic user",
    "timestamp": "$timestamp",
    "uuid": "$uuid",
    "ulid": "$ulid"
  }
}
```

Where:
- `$1`, `$2`, `$3`, etc. are replaced with wildcard values (e.g., `123`)
- `$timestamp` resolves to the current ISO 8601 timestamp
- `$uuid` generates a new UUID v4
- `$ulid` generates a new ULID (Universally Unique Lexicographically Sortable Identifier)

You can also define **custom placeholders**:

```dart
await MayrFakeApi.init(
  basePath: 'assets/api',
  attachTo: dio,
  customPlaceholders: {
    'sessionId': () => 'session-${DateTime.now().millisecondsSinceEpoch}',
    'apiVersion': () => 'v2.0',
  },
);
```

Then in your JSON:

```json
{
  "statusCode": 200,
  "data": {
    "sessionId": "$sessionId",
    "apiVersion": "$apiVersion"
  }
}
```

---

### Example in Action

Given this structure:

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

* You can include **multiple wildcards**, e.g. `/api/user/-/posts/-/get.json`.
  Placeholders `$1`, `$2`, `$3`, etc. will be replaced accordingly.
* If no placeholder is found, the file is returned as-is.
* Works seamlessly with all HTTP methods (`GET`, `POST`, etc.).
* Built-in placeholders: `$timestamp`, `$uuid`, `$ulid`
* Custom placeholders can be defined during initialization to generate dynamic values

---

## 🪶 Empty JSON Files

If a JSON file exists but is **empty**,
the API returns a **204 No Content** response automatically.

---

## 🔌 Example Directory Recap

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
