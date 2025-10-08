/// Represents a fake API response
class MayrFakeResponse {
  /// HTTP status code
  final int statusCode;

  /// Response data
  final dynamic data;

  /// Creates a fake API response
  const MayrFakeResponse({
    required this.statusCode,
    this.data,
  });

  /// Creates a response from JSON
  factory MayrFakeResponse.fromJson(Map<String, dynamic> json) {
    return MayrFakeResponse(
      statusCode: json['statusCode'] as int? ?? 200,
      data: json['data'],
    );
  }

  /// Converts response to JSON
  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data,
    };
  }
}
