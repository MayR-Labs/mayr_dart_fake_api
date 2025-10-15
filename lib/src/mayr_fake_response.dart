/// Represents a fake API response
class MayrFakeResponse {
  /// HTTP status code
  final int statusCode;

  /// Response body (the actual response data)
  final dynamic body;

  /// Optional response headers
  final Map<String, dynamic>? headers;

  /// Optional response cookies
  final Map<String, dynamic>? cookies;

  /// Creates a fake API response
  const MayrFakeResponse({
    required this.statusCode,
    this.body,
    this.headers,
    this.cookies,
  });

  /// Creates a response from JSON
  /// Supports both v2.0 format (body, headers, cookies) and v1.x format (data)
  factory MayrFakeResponse.fromJson(Map<String, dynamic> json) {
    // Support v2.0 format with 'body' or fallback to v1.x 'data' for backward compatibility
    final responseBody = json['body'] ?? json['data'];
    
    return MayrFakeResponse(
      statusCode: json['statusCode'] as int? ?? 200,
      body: responseBody,
      headers: json['headers'] as Map<String, dynamic>?,
      cookies: json['cookies'] as Map<String, dynamic>?,
    );
  }

  /// Converts response to JSON
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'statusCode': statusCode,
      'body': body,
    };
    
    if (headers != null) {
      result['headers'] = headers;
    }
    
    if (cookies != null) {
      result['cookies'] = cookies;
    }
    
    return result;
  }

  /// Legacy getter for backward compatibility
  /// @deprecated Use 'body' instead
  dynamic get data => body;
}
