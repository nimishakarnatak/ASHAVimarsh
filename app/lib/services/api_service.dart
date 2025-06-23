// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../models/vote.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../models/search_response.dart';

class ApiService {
  static const String baseUrl = 'http://34.58.74.142:8001'; // Android emulator
  
  static String? _authToken;
  
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Authentication endpoints
  static Future<ApiResponse<LoginResponse>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authToken = data['access_token'];
        
        final loginResponse = LoginResponse.fromJson(data);
        return ApiResponse.success(loginResponse);
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['detail'] ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  static Future<ApiResponse<User>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);
        return ApiResponse.success(user);
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Question endpoints
  static Future<ApiResponse<List<Question>>> getQuestions({
    int skip = 0,
    int limit = 20,
    String sortBy = 'created_at',
    String order = 'desc',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/questions?skip=$skip&limit=$limit&sort_by=$sortBy&order=$order'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final questions = data.map((json) => Question.fromJson(json)).toList();
        return ApiResponse.success(questions);
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['detail'] ?? 'Failed to fetch questions');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  static Future<ApiResponse<Question>> getQuestion(int questionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/questions/$questionId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final question = Question.fromJson(data);
        return ApiResponse.success(question);
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['detail'] ?? 'Question not found');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  static Future<ApiResponse<Question>> createQuestion(String title, String content, List<String> tags) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/questions'),
        headers: _headers,
        body: json.encode({
          'title': title,
          'content': content,
          'tags': tags,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final question = Question.fromJson(data);
        return ApiResponse.success(question);
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['detail'] ?? 'Failed to create question');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Answer endpoints
  static Future<ApiResponse<List<Answer>>> getAnswers(int questionId, {
    int skip = 0,
    int limit = 20,
    String sortBy = 'created_at',
    String order = 'desc',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/questions/$questionId/answers?skip=$skip&limit=$limit&sort_by=$sortBy&order=$order'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final answers = data.map((json) => Answer.fromJson(json)).toList();
        return ApiResponse.success(answers);
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['detail'] ?? 'Failed to fetch answers');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  static Future<ApiResponse<Answer>> createAnswer(int questionId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/questions/$questionId/answers'),
        headers: _headers,
        body: json.encode({
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final answer = Answer.fromJson(data);
        return ApiResponse.success(answer);
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['detail'] ?? 'Failed to create answer');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Voting endpoints
  static Future<ApiResponse<Vote>> vote(int? questionId, int? answerId, int voteType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vote'),
        headers: _headers,
        body: json.encode({
          'question_id': questionId,
          'answer_id': answerId,
          'vote_type': voteType,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vote = Vote.fromJson(data);
        return ApiResponse.success(vote);
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['detail'] ?? 'Failed to vote');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Search endpoint
  static Future<ApiResponse<SearchResponse>> search(String query, {
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=$query&skip=$skip&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final searchResponse = SearchResponse.fromJson(data);
        return ApiResponse.success(searchResponse);
      } else {
        final error = json.decode(response.body);
        return ApiResponse.error(error['detail'] ?? 'Search failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Clear auth token (logout)
  static void clearAuthToken() {
    _authToken = null;
  }
}
