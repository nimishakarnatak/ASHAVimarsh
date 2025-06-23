class HealthResponse {
  final String status;
  final DateTime timestamp;

  HealthResponse({
    required this.status,
    required this.timestamp,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] ?? 'unknown',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isHealthy => status.toLowerCase() == 'healthy';

  @override
  String toString() {
    return 'HealthResponse{status: $status, timestamp: $timestamp}';
  }
}