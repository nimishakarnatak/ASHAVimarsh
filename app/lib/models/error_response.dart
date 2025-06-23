class ErrorResponse {
  final String message;
  final String? detail;
  final int? statusCode;
  final DateTime timestamp;

  ErrorResponse({
    required this.message,
    this.detail,
    this.statusCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] ?? json['detail'] ?? 'An error occurred',
      detail: json['detail'],
      statusCode: json['status_code'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'detail': detail,
      'status_code': statusCode,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ErrorResponse{message: $message, statusCode: $statusCode}';
  }
}
