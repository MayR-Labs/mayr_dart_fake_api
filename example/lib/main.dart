import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mayr_fake_api/mayr_fake_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dio
  final dio = Dio();

  // Initialize MayrFakeApi
  await MayrFakeApi.init(
    basePath: 'assets/api',
    attachTo: dio,
    delay: const Duration(milliseconds: 500),
    enabled: kDebugMode,
    resolveNotFound: (path, method) {
      return MayrFakeResponse(
        statusCode: 404,
        data: {
          'error': 'No fake endpoint found for $method $path',
          'message': 'Please create the corresponding JSON file',
        },
      );
    },
  );

  runApp(MyApp(dio: dio));
}

class MyApp extends StatelessWidget {
  final Dio dio;

  const MyApp({super.key, required this.dio});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MayrFakeApi Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomePage(dio: dio),
    );
  }
}

class HomePage extends StatefulWidget {
  final Dio dio;

  const HomePage({super.key, required this.dio});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _result = 'No request made yet';
  bool _loading = false;

  Future<void> _makeRequest(String endpoint, String method) async {
    setState(() {
      _loading = true;
      _result = 'Loading...';
    });

    try {
      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await widget.dio.get(endpoint);
          break;
        case 'POST':
          response = await widget.dio.post(endpoint);
          break;
        case 'PUT':
          response = await widget.dio.put(endpoint);
          break;
        case 'DELETE':
          response = await widget.dio.delete(endpoint);
          break;
        default:
          response = await widget.dio.get(endpoint);
      }

      setState(() {
        _result = 'Success!\n'
            'Status: ${response.statusCode}\n'
            'Data: ${response.data}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MayrFakeApi Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Endpoints',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRequestButton(
              'GET User Profile',
              'https://example.com/api/user/profile',
              'GET',
            ),
            _buildRequestButton(
              'POST User Profile',
              'https://example.com/api/user/profile',
              'POST',
            ),
            _buildRequestButton(
              'GET Dynamic User (123)',
              'https://example.com/api/user/123/profile',
              'GET',
            ),
            _buildRequestButton(
              'GET Products',
              'https://example.com/api/products',
              'GET',
            ),
            _buildRequestButton(
              'GET Product Details',
              'https://example.com/api/products/details',
              'GET',
            ),
            _buildRequestButton(
              'GET Empty File',
              'https://example.com/api/empty',
              'GET',
            ),
            _buildRequestButton(
              'GET Not Found',
              'https://example.com/api/notfound',
              'GET',
            ),
            const SizedBox(height: 24),
            const Text(
              'Result:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Text(
                      _result,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestButton(String label, String endpoint, String method) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        onPressed: _loading ? null : () => _makeRequest(endpoint, method),
        child: Text('$label ($method)'),
      ),
    );
  }
}
